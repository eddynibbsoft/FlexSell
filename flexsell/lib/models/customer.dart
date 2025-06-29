class Customer {
  int? id; // Changed from String? to int?
  String name;
  String phone;
  double prepaidBalance;
  double creditOwed;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.prepaidBalance = 0.0,
    this.creditOwed = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'prepaidBalance': prepaidBalance,
      'creditOwed': creditOwed,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      prepaidBalance: map['prepaidBalance'] ?? 0.0,
      creditOwed: map['creditOwed'] ?? 0.0,
    );
  }
}
