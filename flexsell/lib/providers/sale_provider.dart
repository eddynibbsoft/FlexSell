import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/sale.dart';
import '../models/customer.dart';
import '../models/product.dart';

class SaleProvider extends ChangeNotifier {
  final DatabaseHelper? db;
  List<Sale> _sales = [];

  SaleProvider(this.db) {
    loadSales();
  }

  List<Sale> get sales => List.unmodifiable(_sales);

  Future<void> loadSales() async {
    if (db == null) return;
    _sales = await db!.getAllSales();
    notifyListeners();
  }

  Future<void> createSale({
    required int productId,
    required int customerId,
  }) async {
    if (db == null) return;
    final product = await db!.getProductById(productId);
    final customer = await db!.getCustomerById(customerId);

    if (product == null || customer == null) {
      return;
    }

    // Wallet logic
    double amountToDeduct;
    if (customer.prepaidBalance >= product.cashPrice) {
      amountToDeduct = product.cashPrice;
    } else {
      // Not enough funds, use credit price
      amountToDeduct = product.creditPrice;
    }

    // Update balance
    customer.prepaidBalance -= amountToDeduct;

    final sale = Sale(
      productId: productId,
      customerId: customerId,
      amountPaid: amountToDeduct,
      paymentType: 'Wallet', // Keep for record purposes
      date: DateTime.now(),
    );

    await db!.insertSale(sale);
    await db!.updateCustomer(customer);
    await loadSales();
  }

  Future<void> addFundsToWallet({
    required int customerId,
    required double amount,
  }) async {
    if (db == null) return;
    final customer = await db!.getCustomerById(customerId);
    if (customer == null) return;

    customer.prepaidBalance += amount;
    await db!.updateCustomer(customer);
    await loadSales();
  }

  Future<List<Map<String, dynamic>>> getSalesWithDetails() async {
    if (db == null) return [];
    return await db!.getSalesWithDetails(); // uses the raw query method
  }

  String getCustomerStatement(int customerId) {
    final customerSales = _sales.where((s) => s.customerId == customerId);
    final totalSpent = customerSales.fold(0.0, (sum, s) => sum + s.amountPaid);

    return 'Total Spent: \$${totalSpent.toStringAsFixed(2)}';
  }
  
}
