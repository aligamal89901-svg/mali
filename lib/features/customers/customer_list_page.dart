import 'package:flutter/material.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/customer.dart';

class CustomerListPage extends StatefulWidget {
  final String? filter; // 'debtors' or null

  const CustomerListPage({super.key, this.filter});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<Customer> customers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => isLoading = true);
    final allCustomers = await DatabaseHelper.instance.getCustomers();
    
    if (widget.filter == 'debtors') {
      customers = allCustomers.where((c) => c.balance > 0).toList();
    } else {
      customers = allCustomers;
    }
    
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.filter == 'debtors' ? 'الذمم (الباقي عليهم)' : 'قائمة العملاء',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1976D2),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن عميل...',
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
                : customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              widget.filter == 'debtors' ? 'لا يوجد عملاء لديهم رصيد مستحق' : 'لا توجد عملاء مضافين بعد',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final c = customers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.person_rounded, color: Color(0xFF1976D2)),
                              ),
                              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text(c.phone ?? 'لا يوجد رقم'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${c.balance.toStringAsFixed(2)} ر.س',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: c.balance > 0 ? Colors.red : Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    c.balance > 0 ? 'عليه' : 'له',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
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
}