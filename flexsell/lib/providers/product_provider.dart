
// providers/product_provider.dart
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart';  // For ChangeNotifier
import 'package:flutter/widgets.dart';     // For Widget, BuildContext, StatelessWidget, etc.

import '../db/database_helper.dart';       // Adjust relative path for your DatabaseHelper
import '../models/product.dart';            // Adjust relative path for Product model

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper db;
  List<Product> _products = [];

  ProductProvider(this.db) {
    loadProducts();
  }

  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await db.getAllProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await db.insertProduct(product);
    await loadProducts();
  }
}
