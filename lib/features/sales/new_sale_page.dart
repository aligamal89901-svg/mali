import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/product.dart';
import '../../data/models/customer.dart';
import '../../data/models/invoice.dart';
import '../../services/pdf_service.dart';

class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  final List<_SaleItem> _items = [];
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  final _db = DatabaseHelper.instance;

  final TextEditingController _customerSearchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<Customer> _customerSuggestions = [];
  Customer? _selectedCustomer;
  String _paymentType = 'cash';
  double _discountPercent = 0;

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _discountAmount {
    return _subtotal * (_discountPercent / 100);
  }

  double get _totalAmount {
    return _subtotal - _discountAmount;
  }

  double get _remainingAmount {
    if (_paymentType == 'cash') return 0;
    final paid = double.tryParse(_paidAmountController.text) ?? 0;
    return _totalAmount - paid;
  }

  Future<void> _searchProduct(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final results = await _db.searchProducts(query);
    setState(() => _searchResults = results);
  }

  Future<void> _searchCustomer(String query) async {
    if (query.isEmpty) {
      setState(() {
        _customerSuggestions = [];
        _selectedCustomer = null;
      });
      return;
    }
    final results = await _db.searchCustomers(query);
    setState(() => _customerSuggestions = results);
  }

  void _addToSale(Product product) {
    SystemSound.play(SystemSoundType.click);
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      setState(() => _items[existingIndex].quantity++);
    } else {
      setState(() => _items.add(_SaleItem(product: product, quantity: 1, price: product.price1)));
    }
    _searchController.clear();
    setState(() => _searchResults = []);
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity > 0) setState(() => _items[index].quantity = quantity);
  }

  void _showCheckoutDialog() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الفاتورة فارغة'), backgroundColor: Colors.red),
      );
      return;
    }

    _customerSearchController.clear();
    _discountController.clear();
    _paidAmountController.clear();
    _noteController.clear();
    _selectedCustomer = null;
    _customerSuggestions = [];
    _paymentType = 'cash';
    _discountPercent = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
                  const Text('إتمام الفاتورة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  const Text('اسم العميل', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customerSearchController,
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن عميل أو اكتب اسماً جديداً...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_search_rounded),
                    ),
                    onChanged: (value) {
                      _searchCustomer(value);
                      setDialogState(() {});
                    },
                  ),
                  if (_customerSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: ListView.builder(
                        itemCount: _customerSuggestions.length,
                        itemBuilder: (context, index) {
                          final c = _customerSuggestions[index];
                          return ListTile(
                            dense: true,
                            title: Text(c.name),
                            subtitle: Text('رصيد: ${c.balance}'),
                            onTap: () {
                              setDialogState(() {
                                _selectedCustomer = c;
                                _customerSearchController.text = c.name;
                                _customerSuggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),

                  const Text('نوع الدفع', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text('نقداً'),
                          value: 'cash',
                          groupValue: _paymentType,
                          onChanged: (v) => setDialogState(() {
                            _paymentType = v!;
                            _paidAmountController.text = _totalAmount.toStringAsFixed(2);
                          }),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text('آجل'),
                          value: 'credit',
                          groupValue: _paymentType,
                          onChanged: (v) => setDialogState(() {
                            _paymentType = v!;
                            _paidAmountController.clear();
                          }),
                        ),
                      ),
                    ],
                  ),

                  if (_paymentType == 'credit') ...[
                    TextField(
                      controller: _paidAmountController,
                      decoration: const InputDecoration(
                        labelText: 'المبلغ المدفوع',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _discountController,
                          decoration: const InputDecoration(
                            labelText: 'خصم (%)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.percent),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            _discountPercent = double.tryParse(v) ?? 0;
                            setDialogState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'قيمة الخصم: ${_discountAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

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
                            const Text('المجموع الفرعي:'),
                            Text('${_subtotal.toStringAsFixed(2)} ر.س'),
                          ],
                        ),
                        if (_discountAmount > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الخصم:'),
                              Text(
                                '-${_discountAmount.toStringAsFixed(2)} ر.س',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الإجمالي النهائي:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              '${_totalAmount.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        if (_paymentType == 'credit') ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('المتبقي:', style: TextStyle(color: Colors.red)),
                              Text(
                                '${_remainingAmount.toStringAsFixed(2)} ر.س',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _processInvoice(setDialogState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text(
                          'إنشاء الفاتورة',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processInvoice(StateSetter setDialogState) async {
    int customerId;
    String customerName;
    double customerBalance = 0;

    if (_selectedCustomer != null) {
      customerId = _selectedCustomer!.id!;
      customerName = _selectedCustomer!.name;
      customerBalance = _selectedCustomer!.balance;
    } else {
      final newC = Customer(name: _customerSearchController.text.trim(), balance: 0);
      customerId = await _db.createCustomer(newC);
      customerName = newC.name;
    }

    double finalRemaining = _remainingAmount;
    if (_paymentType == 'credit' && finalRemaining > 0) {
      customerBalance += finalRemaining;
      await _db.updateCustomerBalance(customerId, customerBalance);
    }

    final itemsList = _items.map((item) => {
      'productId': item.product.id,
      'name': item.product.name,
      'quantity': item.quantity,
      'price': item.price,
      'total': item.price * item.quantity,
    }).toList();
    final itemsJson = jsonEncode(itemsList);

    final invoice = Invoice(
      date: DateTime.now(),
      customerId: customerId,
      customerName: customerName,
      totalAmount: _totalAmount,
      paidAmount: _paymentType == 'cash' ? _totalAmount : (double.tryParse(_paidAmountController.text) ?? 0),
      remainingAmount: finalRemaining,
      paymentType: _paymentType,
      itemsJson: itemsJson,
    );

    final invoiceId = await _db.createInvoice(invoice);
    final savedInvoice = Invoice(
      id: invoiceId,
      date: invoice.date,
      customerId: invoice.customerId,
      customerName: invoice.customerName,
      totalAmount: invoice.totalAmount,
      paidAmount: invoice.paidAmount,
      remainingAmount: invoice.remainingAmount,
      paymentType: invoice.paymentType,
      itemsJson: invoice.itemsJson,
    );

    Navigator.pop(context);
    _showSuccessDialog(savedInvoice, itemsList);
  }

  void _showSuccessDialog(Invoice invoice, List<Map<String, dynamic>> items) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('تم إنشاء الفاتورة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'رقم الفاتورة: #${invoice.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => PdfService.shareInvoice(invoice, items),
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة'),
                ),
                ElevatedButton.icon(
                  onPressed: () => PdfService.printInvoice(invoice, items),
                  icon: const Icon(Icons.print),
                  label: const Text('طباعة/PDF'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _items.clear());
            },
            child: const Text('إنهاء فاتورة جديدة', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('فاتورة بيع جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1976D2),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1976D2)),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchProduct,
            ),
          ),
          if (_searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              color: Colors.white,
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final p = _searchResults[index];
                  return ListTile(
                    dense: true,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF1976D2), size: 20),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${p.price1} ر.س', style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.add_circle_rounded, color: Color(0xFF4CAF50), size: 24),
                    onTap: () => _addToSale(p),
                  );
                },
              ),
            ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'الفاتورة فارغة',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    '${item.price} ر.س',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () => _updateQuantity(index, item.quantity - 1),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1976D2).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.remove_rounded, size: 16, color: Color(0xFF1976D2)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _updateQuantity(index, item.quantity + 1),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1976D2).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF1976D2)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${(item.price * item.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const Text('ر.س', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => _removeItem(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete_rounded, size: 16, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (_items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('الإجمالي:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          '${_totalAmount.toStringAsFixed(2)} ر.س',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCheckoutDialog,
                    icon: const Icon(Icons.calculate_rounded),
                    label: const Text('حاسب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SaleItem {
  final Product product;
  int quantity;
  final double price;
  _SaleItem({required this.product, required this.quantity, required this.price});
}