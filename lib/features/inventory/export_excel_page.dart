import 'package:flutter/material.dart';

class ExportExcelPage extends StatelessWidget {
  const ExportExcelPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تصدير إلى Excel'), centerTitle: true),
      body: const Center(child: Text('هذه الميزة قيد التطوير', style: TextStyle(fontSize: 18, color: Colors.grey))),
    );
  }
}