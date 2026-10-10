class Product {
  final int? id;
  final String barcode;
  final String name;
  final String? description;
  final double price1;
  final double price2;
  final double price3;
  final double costPrice;
  final double quantity;
  final double reorderLevel;
  final DateTime? expiryDate;
  final double tax;
  final int? categoryId;
  final String unit;
  final String? imageUrl;

  Product({
    this.id,
    required this.barcode,
    required this.name,
    this.description,
    required this.price1,
    this.price2 = 0,
    this.price3 = 0,
    required this.costPrice,
    this.quantity = 0,
    this.reorderLevel = 0,
    this.expiryDate,
    this.tax = 0,
    this.categoryId,
    this.unit = 'piece',
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'description': description,
      'price1': price1,
      'price2': price2,
      'price3': price3,
      'costPrice': costPrice,
      'quantity': quantity,
      'reorderLevel': reorderLevel,
      'expiryDate': expiryDate?.toIso8601String(),
      'tax': tax,
      'categoryId': categoryId,
      'unit': unit,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      barcode: map['barcode'],
      name: map['name'],
      description: map['description'],
      price1: map['price1']?.toDouble() ?? 0.0,
      price2: map['price2']?.toDouble() ?? 0.0,
      price3: map['price3']?.toDouble() ?? 0.0,
      costPrice: map['costPrice']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toDouble() ?? 0.0,
      reorderLevel: map['reorderLevel']?.toDouble() ?? 0.0,
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      tax: map['tax']?.toDouble() ?? 0.0,
      categoryId: map['categoryId'],
      unit: map['unit'] ?? 'piece',
      imageUrl: map['imageUrl'],
    );
  }
}