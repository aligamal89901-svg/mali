import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/invoice.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // بيانات الويب في الذاكرة
  final List<Product> _webProducts = [];
  final List<Category> _webCategories = [];
  final List<Customer> _webCustomers = [];
  final List<Invoice> _webInvoices = [];
  int _webProductId = 1;
  int _webCategoryId = 1;
  int _webCustomerId = 1;
  int _webInvoiceId = 1;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) throw Exception('Database not available on web');
    if (_database != null) return _database!;
    _database = await _initDB('mali.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        description $textTypeNullable
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id $idType,
        barcode $textType,
        name $textType,
        description $textTypeNullable,
        price1 $realType,
        price2 $realType,
        price3 $realType,
        costPrice $realType,
        quantity $realType,
        reorderLevel $realType,
        expiryDate $textTypeNullable,
        tax $realType,
        categoryId INTEGER,
        unit $textType,
        imageUrl $textTypeNullable,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        name $textType,
        phone $textTypeNullable,
        address $textTypeNullable,
        balance $realType
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id $idType,
        date $textType,
        customerId $integerType,
        customerName $textType,
        totalAmount $realType,
        paidAmount $realType,
        remainingAmount $realType,
        paymentType $textType,
        itemsJson $textType,
        FOREIGN KEY (customerId) REFERENCES customers (id)
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const textTypeNullable = 'TEXT';
      const realType = 'REAL NOT NULL';
      const integerType = 'INTEGER NOT NULL';

      await db.execute('''
        CREATE TABLE IF NOT EXISTS customers (
          id $idType,
          name $textType,
          phone $textTypeNullable,
          address $textTypeNullable,
          balance $realType
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS invoices (
          id $idType,
          date $textType,
          customerId $integerType,
          customerName $textType,
          totalAmount $realType,
          paidAmount $realType,
          remainingAmount $realType,
          paymentType $textType,
          itemsJson $textType,
          FOREIGN KEY (customerId) REFERENCES customers (id)
        )
      ''');
    }
  }

  // ==================== Products ====================
  
  Future<int> createProduct(Product product) async {
    if (kIsWeb) {
      _webProducts.add(Product(id: _webProductId++, barcode: product.barcode, name: product.name, price1: product.price1, costPrice: product.costPrice, quantity: product.quantity));
      return _webProductId - 1;
    }
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    if (kIsWeb) return _webProducts;
    final db = await database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    if (kIsWeb) {
      return _webProducts
          .where((p) => p.name.contains(query) || p.barcode.contains(query))
          .toList();
    }
    final db = await database;
    final result = await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<int> updateProduct(Product product) async {
    if (kIsWeb) {
      final index = _webProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) _webProducts[index] = product;
      return 1;
    }
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    if (kIsWeb) {
      _webProducts.removeWhere((p) => p.id == id);
      return 1;
    }
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Categories ====================
  
  Future<int> createCategory(Category category) async {
    if (kIsWeb) {
      _webCategories.add(Category(id: _webCategoryId++, name: category.name, description: category.description));
      return _webCategoryId - 1;
    }
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    if (kIsWeb) return _webCategories;
    final db = await database;
    final result = await db.query('categories');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  // ==================== Customers ====================
  
  Future<int> createCustomer(Customer customer) async {
    if (kIsWeb) {
      _webCustomers.add(Customer(id: _webCustomerId++, name: customer.name, phone: customer.phone, address: customer.address, balance: customer.balance));
      return _webCustomerId - 1;
    }
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getCustomers() async {
    if (kIsWeb) return _webCustomers;
    final db = await database;
    final result = await db.query('customers');
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  Future<List<Customer>> searchCustomers(String query) async {
    if (kIsWeb) {
      return _webCustomers.where((c) => c.name.contains(query)).toList();
    }
    final db = await database;
    final result = await db.query(
      'customers',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  Future<int> updateCustomerBalance(int customerId, double newBalance) async {
    if (kIsWeb) {
      final index = _webCustomers.indexWhere((c) => c.id == customerId);
      if (index != -1) {
        _webCustomers[index] = Customer(
          id: _webCustomers[index].id,
          name: _webCustomers[index].name,
          phone: _webCustomers[index].phone,
          address: _webCustomers[index].address,
          balance: newBalance,
        );
      }
      return 1;
    }
    final db = await database;
    return await db.update(
      'customers',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  // ==================== Invoices ====================
  
  Future<int> createInvoice(Invoice invoice) async {
    if (kIsWeb) {
      _webInvoices.add(Invoice(
        id: _webInvoiceId++,
        date: invoice.date,
        customerId: invoice.customerId,
        customerName: invoice.customerName,
        totalAmount: invoice.totalAmount,
        paidAmount: invoice.paidAmount,
        remainingAmount: invoice.remainingAmount,
        paymentType: invoice.paymentType,
        itemsJson: invoice.itemsJson,
      ));
      return _webInvoiceId - 1;
    }
    final db = await database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<List<Invoice>> getInvoices() async {
    if (kIsWeb) return _webInvoices;
    final db = await database;
    final result = await db.query('invoices', orderBy: 'date DESC');
    return result.map((json) => Invoice.fromMap(json)).toList();
  }

  Future close() async {
    if (kIsWeb) return;
    final db = await database;
    db.close();
  }
}