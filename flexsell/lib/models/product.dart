class Product {
  final int? id;
  final String name;
  final double cashPrice;
  final double creditPrice;

  Product({
    this.id,
    required this.name,
    required this.cashPrice,
    required this.creditPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // avoid inserting null for auto-incremented id
      'name': name,
      'cashPrice': cashPrice,
      'creditPrice': creditPrice,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      cashPrice: (map['cashPrice'] as num).toDouble(),
      creditPrice: (map['creditPrice'] as num).toDouble(),
    );
  }
}
