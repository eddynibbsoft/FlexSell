// providers/customer_provider.dart
import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final DatabaseHelper db;
  List<Customer> _customers = [];

  CustomerProvider(this.db) {
    loadCustomers();
  }

  List<Customer> get customers => List.unmodifiable(_customers); // Safer access

  // READ
  Future<void> loadCustomers() async {
    _customers = await db.getAllCustomers();
    notifyListeners();
  }

  // CREATE
  Future<void> addCustomer(Customer customer) async {
    await db.insertCustomer(customer);
    await loadCustomers();
  }

  // UPDATE
  Future<void> updateCustomer(Customer customer) async {
    await db.updateCustomer(customer);
    await loadCustomers();
  }

  // DELETE
  Future<void> deleteCustomer(int id) async {
    await db.deleteCustomer(id);
    await loadCustomers();
  }

  // Optional: FIND BY ID
  Customer? findById(int id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
