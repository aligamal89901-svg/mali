import 'package:flutter/material.dart';
import '../sales/sales_page.dart';
import '../purchases/purchases_page.dart';
import '../customers/customers_page.dart';
import '../suppliers/suppliers_page.dart';
import '../cashbox/cashbox_page.dart';
import '../expenses/expenses_page.dart';
import '../inventory/inventory_page.dart';
import '../queries/queries_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'مالي | MALI',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              // إعدادات التطبيق لاحقاً
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم الترحيب
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF03A9F4)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً بك في مالي',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'نظامك المالي المتكامل في مكان واحد',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildStatCard('المبيعات', '0', Icons.trending_up),
                        const SizedBox(width: 12),
                        _buildStatCard('المنتجات', '0', Icons.inventory),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // عنوان القسم
              const Text(
                'الخدمات الرئيسية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              
              // الأزرار الرئيسية
              _buildMainButton(
                context,
                title: 'المبيعات',
                subtitle: 'إدارة عمليات البيع',
                icon: Icons.point_of_sale_rounded,
                color: const Color(0xFF1976D2),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesPage())),
              ),
              const SizedBox(height: 12),
              _buildMainButton(
                context,
                title: 'المشتريات',
                subtitle: 'إدارة عمليات الشراء',
                icon: Icons.shopping_cart_rounded,
                color: const Color(0xFF03A9F4),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesPage())),
              ),
              const SizedBox(height: 12),
              _buildMainButton(
                context,
                title: 'المخزون',
                subtitle: 'إدارة المنتجات والمخزون',
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFFFF9800),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryPage())),
              ),
              const SizedBox(height: 12),
              _buildMainButton(
                context,
                title: 'العملاء',
                subtitle: 'إدارة بيانات العملاء',
                icon: Icons.people_rounded,
                color: const Color(0xFF4CAF50),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersPage())),
              ),
              const SizedBox(height: 12),
              _buildMainButton(
                context,
                title: 'الموردون',
                subtitle: 'إدارة بيانات الموردين',
                icon: Icons.local_shipping_rounded,
                color: const Color(0xFF9C27B0),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersPage())),
              ),
              const SizedBox(height: 12),
              _buildMainButton(
                context,
                title: 'الصندوق',
                subtitle: 'إدارة النقدية والحركات المالية',
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFFE91E63),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CashboxPage())),
              ),
              const SizedBox(height: 12),
              _buildMainButton(
                context,
                title: 'المصروفات',
                subtitle: 'تسجيل ومتابعة المصروفات',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF795548),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesPage())),
              ),
              const SizedBox(height: 12),
              _buildMainButton(
                context,
                title: 'الاستعلامات',
                subtitle: 'تقارير وإحصائيات شاملة',
                icon: Icons.search_rounded,
                color: const Color(0xFF607D8B),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QueriesPage())),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}