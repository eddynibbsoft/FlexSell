class Sale {
  int? id;
  int productId;          // <- changed from String
  int customerId;         // <- changed from String
  double amountPaid;
  String paymentType; // 'Cash' or 'Credit'
  DateTime date;

  Sale({
    this.id,
    required this.productId,
    required this.customerId,
    required this.amountPaid,
    required this.paymentType,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'customerId': customerId,
      'amountPaid': amountPaid,
      'paymentType': paymentType,
      'date': date.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      productId: map['productId'],
      customerId: map['customerId'],
      amountPaid: map['amountPaid'],
      paymentType: map['paymentType'],
      date: DateTime.parse(map['date']),
    );
  }
}
