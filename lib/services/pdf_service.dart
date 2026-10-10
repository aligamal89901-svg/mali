import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/invoice.dart';

class PdfService {
  static pw.Font? _font;
  static pw.Font? _fontBold;
  static bool _fontsLoaded = false;

  static Future<void> _loadFonts() async {
    if (_fontsLoaded) return;
    
    try {
      // محاولة تحميل الخطوط من assets
      final regularData = await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf');
      
      _font = pw.Font.ttf(regularData);
      _fontBold = pw.Font.ttf(boldData);
      _fontsLoaded = true;
      print('✅ تم تحميل الخطوط من assets بنجاح');
    } catch (e) {
      print('️ فشل تحميل الخطوط من assets: $e');
      try {
        // fallback: تحميل من Google Fonts
        _font = await PdfGoogleFonts.notoSansArabicRegular();
        _fontBold = await PdfGoogleFonts.notoSansArabicBold();
        _fontsLoaded = true;
        print('✅ تم تحميل الخطوط من Google Fonts');
      } catch (e2) {
        print('❌ فشل تحميل الخطوط من Google Fonts: $e2');
        // fallback أخير: استخدام Helvetica
        _font = pw.Font.helvetica();
        _fontBold = pw.Font.helveticaBold();
        _fontsLoaded = true;
        print('⚠️ استخدام خط Helvetica كخط أخير');
      }
    }
  }

  static Future<pw.Document> generateInvoice(Invoice invoice, List<Map<String, dynamic>> items) async {
    await _loadFonts();
    
    final pdf = pw.Document();
    final font = _font!;
    final fontBold = _fontBold!;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('1976D2'),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('مالي', style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.white)),
                      pw.SizedBox(height: 4),
                      pw.Text('نظام إدارة المبيعات', style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.white)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('فاتورة مبيعات', style: pw.TextStyle(font: fontBold, fontSize: 20, color: PdfColors.white)),
                      pw.SizedBox(height: 4),
                      pw.Text('رقم: ${invoice.id}', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.white)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Invoice Info Box
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('F5F7FA'),
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: PdfColor.fromHex('E0E0E0')),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('بيانات العميل', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColor.fromHex('1976D2'))),
                      pw.SizedBox(height: 8),
                      pw.Text('الاسم: ${invoice.customerName}', style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text('التاريخ: ${invoice.date.toLocal().toString().split(' ')[0]}', style: pw.TextStyle(font: font, fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('بيانات الدفع', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColor.fromHex('1976D2'))),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'النوع: ${invoice.paymentType == 'cash' ? 'نقداً' : 'آجل'}',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Items Table
            pw.Text('تفاصيل المنتجات', style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColor.fromHex('2C3E50'))),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColor.fromHex('E0E0E0'), width: 1),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('1976D2')),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text('الصنف', style: pw.TextStyle(font: fontBold, color: PdfColors.white), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text('الكمية', style: pw.TextStyle(font: fontBold, color: PdfColors.white), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text('السعر', style: pw.TextStyle(font: fontBold, color: PdfColors.white), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text('الإجمالي', style: pw.TextStyle(font: fontBold, color: PdfColors.white), textAlign: pw.TextAlign.center)),
                  ],
                ),
                ...items.map((item) => pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(item['name'], style: pw.TextStyle(font: font), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text('${item['quantity']}', style: pw.TextStyle(font: font), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text('${item['price']}', style: pw.TextStyle(font: font), textAlign: pw.TextAlign.center)),
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text('${item['total']}', style: pw.TextStyle(font: fontBold), textAlign: pw.TextAlign.center)),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 20),

            // Totals Box
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('F5F7FA'),
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: PdfColor.fromHex('E0E0E0')),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('الإجمالي الكلي:', style: pw.TextStyle(font: fontBold, fontSize: 16)),
                      pw.Text('${invoice.totalAmount.toStringAsFixed(2)} ر.س', style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColor.fromHex('1976D2'))),
                    ],
                  ),
                  if (invoice.paymentType == 'credit') ...[
                    pw.SizedBox(height: 12),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('المبلغ المدفوع:', style: pw.TextStyle(font: font, fontSize: 14)),
                        pw.Text('${invoice.paidAmount.toStringAsFixed(2)} ر.س', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColor.fromHex('4CAF50'))),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('المبلغ المتبقي:', style: pw.TextStyle(font: fontBold, fontSize: 14)),
                        pw.Text('${invoice.remainingAmount.toStringAsFixed(2)} ر.س', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColor.fromHex('F44336'))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('F5F7FA'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('شكراً لتعاملكم معنا', style: pw.TextStyle(font: font, fontSize: 12, color: PdfColor.fromHex('607D8B'))),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  static Future<void> printInvoice(Invoice invoice, List<Map<String, dynamic>> items) async {
    final pdf = await generateInvoice(invoice, items);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> shareInvoice(Invoice invoice, List<Map<String, dynamic>> items) async {
    final pdf = await generateInvoice(invoice, items);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${invoice.id}.pdf',
    );
  }
}