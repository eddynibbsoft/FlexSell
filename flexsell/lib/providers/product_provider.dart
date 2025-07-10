import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final DatabaseHelper db;
  List<Product> _products = [];

  ProductProvider(this.db) {
    loadProducts();
  }

  List<Product> get products => List.unmodifiable(_products); // safer getter

  // READ: Load all products from database
  Future<void> loadProducts() async {
    _products = await db.getAllProducts();
    notifyListeners();
  }

  // CREATE: Insert new product and refresh list
  Future<void> addProduct(Product product) async {
    await db.insertProduct(product);
    await loadProducts();
  }

  // UPDATE: Modify existing product and refresh list
  Future<void> updateProduct(Product product) async {
    await db.updateProduct(product);
    await loadProducts();
  }

  // DELETE: Remove product by ID and refresh list
  Future<void> deleteProduct(int id) async {
    await db.deleteProduct(id);
    await loadProducts();
  }

  // Optional: Find product by ID
  Product? findById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
