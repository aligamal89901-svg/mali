import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/product.dart';
import '../../services/excel_service.dart';
import 'edit_product_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    products = await _db.getProducts();
    setState(() => isLoading = false);
  }

  Future<void> _exportToExcel() async {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد منتجات للتصدير'), backgroundColor: Colors.red),
      );
      return;
    }

    final bytes = ExcelService.exportProducts(products);
    final tempDir = await _getTempDirectory();
    final file = File('${tempDir.path}/products_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], subject: 'تصدير المنتجات - مالي');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تصدير ${products.length} منتج بنجاح'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _importFromExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final importedProducts = ExcelService.importProducts(bytes);

      if (importedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على منتجات في الملف'), backgroundColor: Colors.orange),
        );
        return;
      }

      // تأكيد الاستيراد
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد الاستيراد'),
          content: Text('تم العثور على ${importedProducts.length} منتج. هل تريد إضافتها إلى المخزون؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('استيراد')),
          ],
        ),
      );

      if (confirmed == true) {
        int importedCount = 0;
        for (var product in importedProducts) {
          await _db.createProduct(product);
          importedCount++;
        }

        await _loadProducts();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم استيراد $importedCount منتج بنجاح'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProductPage(product: product)),
    );

    if (result == true) {
      await _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('قائمة المنتجات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_rounded),
            onPressed: _importFromExcel,
            tooltip: 'استيراد من Excel',
          ),
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            onPressed: _exportToExcel,
            tooltip: 'تصدير إلى Excel',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الباركود...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1976D2)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // يمكن إضافة منطق البحث هنا لاحقاً
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
                : products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text('لا توجد منتجات مضافة بعد', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final p = products[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _editProduct(p),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF1976D2)),
                                ),
                                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Text('الكمية: ${p.quantity.toStringAsFixed(0)} | الباركود: ${p.barcode}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${p.price1.toStringAsFixed(2)} ر.س', 
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF50), fontSize: 16)),
                                    const Text('سعر البيع', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<Directory> _getTempDirectory() async {
    // For web, we'll use a different approach
    // This is a simplified version
    return Directory.systemTemp;
  }
}