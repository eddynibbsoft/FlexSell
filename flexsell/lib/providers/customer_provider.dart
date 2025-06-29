
// providers/customer_provider.dart
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart';  // For ChangeNotifier
import 'package:flutter/widgets.dart';     // For Widget, BuildContext, StatelessWidget, etc.

import '../db/database_helper.dart';       // Adjust relative path for your DatabaseHelper
import '../models/customer.dart';            // Adjust relative path for Product model
import '../models/product.dart';
import '../models/sale.dart';

class CustomerProvider extends ChangeNotifier {
  final DatabaseHelper db;
  List<Customer> _customers = [];

  CustomerProvider(this.db) {
    loadCustomers();
  }

  List<Customer> get customers => _customers;

  Future<void> loadCustomers() async {
    _customers = await db.getAllCustomers();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    await db.insertCustomer(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
  await db.updateCustomer(customer);
  await loadCustomers();
}

}
