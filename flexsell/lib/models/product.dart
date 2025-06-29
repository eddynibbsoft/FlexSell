class Product {
  int? id;
  String name;
  double cashPrice;
  double creditPrice;

  Product({
    this.id,
    required this.name,
    required this.cashPrice,
    required this.creditPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cashPrice': cashPrice,
      'creditPrice': creditPrice,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      cashPrice: map['cashPrice'],
      creditPrice: map['creditPrice'],
    );
  }
}
