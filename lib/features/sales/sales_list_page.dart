import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/invoice.dart';
import '../../services/pdf_service.dart';

class SalesListPage extends StatefulWidget {
  const SalesListPage({super.key});

  @override
  State<SalesListPage> createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  List<Invoice> invoices = [];
  bool isLoading = true;
  final _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => isLoading = true);
    invoices = await _db.getInvoices();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('سجل الفواتير', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1976D2),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
          : invoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('لا توجد فواتير مسجلة', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    final isCredit = invoice.paymentType == 'credit';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showInvoiceDetails(invoice),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isCredit ? const Color(0xFFFF9800).withOpacity(0.1) : const Color(0xFF4CAF50).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isCredit ? Icons.credit_card_rounded : Icons.payments_rounded,
                                          color: isCredit ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'فاتورة #${invoice.id}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            invoice.customerName,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${invoice.totalAmount.toStringAsFixed(2)} ر.س',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1976D2)),
                                      ),
                                      Text(
                                        invoice.date.toLocal().toString().split(' ')[0],
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (isCredit) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('المتبقي:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      Text(
                                        '${invoice.remainingAmount.toStringAsFixed(2)} ر.س',
                                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    List<Map<String, dynamic>> items = [];
    try {
      items = List<Map<String, dynamic>>.from(jsonDecode(invoice.itemsJson));
    } catch (e) {}

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('تفاصيل الفاتورة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('رقم: #${invoice.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('العميل: ${invoice.customerName}'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(invoice.paymentType == 'cash' ? 'نقداً' : 'آجل', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(invoice.date.toLocal().toString().split(' ')[0]),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('المنتجات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 3, child: Text('الصنف', style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: Text('الكمية', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('السعر', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: Text('الإجمالي', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      ...items.map((item) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 3, child: Text(item['name'])),
                            Expanded(flex: 1, child: Text('${item['quantity']}', textAlign: TextAlign.center)),
                            Expanded(flex: 2, child: Text('${item['price']}', textAlign: TextAlign.center)),
                            Expanded(flex: 2, child: Text('${item['total']}', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي الكلي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${invoice.totalAmount.toStringAsFixed(2)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1976D2))),
                        ],
                      ),
                      if (invoice.paymentType == 'credit') ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المدفوع:', style: TextStyle(color: Colors.green)),
                            Text('${invoice.paidAmount.toStringAsFixed(2)} ر.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المتبقي:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            Text('${invoice.remainingAmount.toStringAsFixed(2)} ر.س', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        PdfService.shareInvoice(invoice, items);
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('مشاركة PDF'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        PdfService.printInvoice(invoice, items);
                      },
                      icon: const Icon(Icons.print_rounded),
                      label: const Text('طباعة'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}