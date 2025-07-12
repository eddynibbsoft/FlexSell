import 'package:flutter/material.dart';
import 'package:flexsell/models/sale.dart';
import 'package:flexsell/providers/sale_provider.dart';
import '../db/database_helper.dart';

class DummySaleProvider extends ChangeNotifier implements SaleProvider {
  @override
  final DatabaseHelper? db;

  DummySaleProvider() : db = null; // Dummy db for web

  @override
  List<Sale> get sales => [];

  @override
  Future<void> loadSales() async {
    // No-op for web
  }

  @override
  Future<void> createSale({
    required int productId,
    required int customerId,
  }) async {
    // No-op for web
  }

  @override
  Future<void> deleteSale(int id) async {
    // No-op for web
  }

  @override
  Future<void> addFundsToWallet({
    required int customerId,
    required double amount,
  }) async {
    // No-op for web
  }

  @override
  Future<List<Map<String, dynamic>>> getSalesWithDetails() async {
    return []; // No-op for web
  }

  @override
  String getCustomerStatement(int customerId) {
    return ''; // No-op for web
  }
}