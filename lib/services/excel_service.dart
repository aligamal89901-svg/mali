import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../data/models/product.dart';

class ExcelService {
  static Excel _createExcel(List<Product> products) {
    final excel = Excel.createExcel();
    final sheet = excel['المنتجات'];

    sheet.appendRow([
      TextCellValue('الباركود'),
      TextCellValue('اسم المنتج'),
      TextCellValue('سعر البيع'),
      TextCellValue('سعر التكلفة'),
      TextCellValue('الكمية'),
    ]);

    for (var product in products) {
      sheet.appendRow([
        TextCellValue(product.barcode),
        TextCellValue(product.name),
        DoubleCellValue(product.price1),
        DoubleCellValue(product.costPrice),
        DoubleCellValue(product.quantity),
      ]);
    }

    return excel;
  }

  static Uint8List exportProducts(List<Product> products) {
    final excel = _createExcel(products);
    // التصحيح هنا: تحويل List<int> إلى Uint8List
    return Uint8List.fromList(excel.encode()!);
  }

  static List<Product> importProducts(Uint8List fileBytes) {
    final excel = Excel.decodeBytes(fileBytes);
    final sheet = excel.tables.values.first;
    final products = <Product>[];

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.length >= 5) {
        final barcode = row[0]?.value?.toString() ?? '';
        final name = row[1]?.value?.toString() ?? '';
        final price1 = double.tryParse(row[2]?.value?.toString() ?? '0') ?? 0.0;
        final costPrice = double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0.0;
        final quantity = double.tryParse(row[4]?.value?.toString() ?? '0') ?? 0.0;

        if (name.isNotEmpty) {
          products.add(Product(
            barcode: barcode,
            name: name,
            price1: price1,
            costPrice: costPrice,
            quantity: quantity,
          ));
        }
      }
    }
    return products;
  }
}