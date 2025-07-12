import 'package:flutter/material.dart';
import 'package:flexsell/models/customer.dart';
import 'package:flexsell/providers/customer_provider.dart';
import '../db/database_helper.dart';

class DummyCustomerProvider extends ChangeNotifier implements CustomerProvider {
  @override
  final DatabaseHelper? db;

  DummyCustomerProvider() : db = null; // Dummy db for web

  @override
  List<Customer> get customers => [];

  @override
  Future<void> loadCustomers() async {
    // No-op for web
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    // No-op for web
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    // No-op for web
  }

  @override
  Future<void> deleteCustomer(int id) async {
    // No-op for web
  }

  @override
  Customer? findById(int id) {
    return null;
  }

  @override
  Future<void> addFundsToWallet(int customerId, double amount) async {
    // No-op for web
  }

  @override
  Future<void> deductFundsFromWallet(int customerId, double amount) async {
    // No-op for web
  }

  @override
  String getCustomerStatement(int customerId) {
    return ''; // No-op for web
  }
}