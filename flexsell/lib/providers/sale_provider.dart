
// providers/sale_provider.dart
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';  // For ChangeNotifier
import 'package:flutter/widgets.dart';     // For Widget, BuildContext, StatelessWidget, etc.
import '../db/database_helper.dart';       // Adjust relative path for your DatabaseHelper
import '../models/sale.dart';            // Adjust relative path for Product model
import '../models/customer.dart';
import '../models/product.dart';


class SaleProvider extends ChangeNotifier {
  final DatabaseHelper db;
  List<Sale> _sales = [];

  SaleProvider(this.db) {
    loadSales();
  }

  Future<void> loadSales() async {
    _sales = await db.getAllSales();
    notifyListeners();
  }

  Future<void> createSale({
    required int productId,
    required int customerId,
    required String paymentType,
  }) async {
    final product = await db.getProductById(productId);
    final customer = await db.getCustomerById(customerId);

    final amount = paymentType == 'Cash' ? product.cashPrice : product.creditPrice;
    final sale = Sale(
      productId: productId,
      customerId: customerId,
      amountPaid: amount,
      paymentType: paymentType,
      date: DateTime.now(),
    );
    await db.insertSale(sale);

    if (paymentType == 'Credit') {
      customer.creditOwed += amount;
    } else if (paymentType == 'Cash' && customer.prepaidBalance >= amount) {
      customer.prepaidBalance -= amount;
    }
    await db.updateCustomer(customer);
    await loadSales();
  }

  String getCustomerStatement(int customerId) {
    final relevantSales = _sales.where((s) => s.customerId == customerId).toList();
    final totalCredit = relevantSales
        .where((s) => s.paymentType == 'Credit')
        .fold(0.0, (sum, s) => sum + s.amountPaid);
    final totalCash = relevantSales
        .where((s) => s.paymentType == 'Cash')
        .fold(0.0, (sum, s) => sum + s.amountPaid);

    return 'Cash Paid: \$${totalCash.toStringAsFixed(2)}\n'
           'Credit Owed: \$${totalCredit.toStringAsFixed(2)}';
  }
}

