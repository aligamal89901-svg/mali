import 'package:flutter/material.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _barcodeController;
  late TextEditingController _nameController;
  late TextEditingController _price1Controller;
  late TextEditingController _costPriceController;
  late TextEditingController _quantityController;
  final _db = DatabaseHelper.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(text: widget.product.barcode);
    _nameController = TextEditingController(text: widget.product.name);
    _price1Controller = TextEditingController(text: widget.product.price1.toString());
    _costPriceController = TextEditingController(text: widget.product.costPrice.toString());
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('تعديل المنتج', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1976D2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_nameController, 'اسم المنتج', Icons.shopping_bag_rounded, isRequired: true),
                const SizedBox(height: 16),
                _buildTextField(_barcodeController, 'الباركود', Icons.qr_code_scanner_rounded),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_price1Controller, 'سعر البيع', Icons.attach_money_rounded, isRequired: true, isNumber: true),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(_costPriceController, 'سعر التكلفة', Icons.account_balance_wallet_rounded, isNumber: true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_quantityController, 'الكمية', Icons.inventory_2_rounded, isNumber: true),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
                    : ElevatedButton(
                        onPressed: _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: const Text('حفظ التعديلات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _deleteProduct,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('حذف المنتج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final updatedProduct = Product(
        id: widget.product.id,
        barcode: _barcodeController.text.trim(),
        name: _nameController.text.trim(),
        price1: double.tryParse(_price1Controller.text) ?? 0.0,
        costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
        quantity: double.tryParse(_quantityController.text) ?? 0.0,
      );

      await _db.updateProduct(updatedProduct);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم تحديث المنتج بنجاح', textAlign: TextAlign.center),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${widget.product.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteProduct(widget.product.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المنتج'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _price1Controller.dispose();
    _costPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}