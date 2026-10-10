class Invoice {
  final int? id;
  final DateTime date;
  final int customerId;
  final String customerName;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String paymentType; // 'cash' or 'credit'
  final String itemsJson; // JSON string of items

  Invoice({
    this.id,
    required this.date,
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentType,
    required this.itemsJson,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'paymentType': paymentType,
      'itemsJson': itemsJson,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      date: DateTime.parse(map['date']),
      customerId: map['customerId'],
      customerName: map['customerName'],
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      paidAmount: map['paidAmount']?.toDouble() ?? 0.0,
      remainingAmount: map['remainingAmount']?.toDouble() ?? 0.0,
      paymentType: map['paymentType'],
      itemsJson: map['itemsJson'],
    );
  }
}