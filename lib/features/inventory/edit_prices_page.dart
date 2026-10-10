import 'package:flutter/material.dart';

class EditPricesPage extends StatelessWidget {
  const EditPricesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الأسعار'), centerTitle: true),
      body: const Center(child: Text('هذه الميزة قيد التطوير', style: TextStyle(fontSize: 18, color: Colors.grey))),
    );
  }
}