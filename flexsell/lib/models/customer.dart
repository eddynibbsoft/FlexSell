class Customer {
  int? id;
  String name;
  String phone;
  double prepaidBalance;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.prepaidBalance = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'prepaidBalance': prepaidBalance,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      prepaidBalance: (map['prepaidBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
