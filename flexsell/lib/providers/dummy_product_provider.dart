import 'package:flutter/material.dart';
import 'package:flexsell/models/product.dart';
import 'package:flexsell/providers/product_provider.dart';
import '../db/database_helper.dart';

class DummyProductProvider extends ChangeNotifier implements ProductProvider {
  @override
  final DatabaseHelper? db;

  DummyProductProvider() : db = null; // Dummy db for web

  @override
  List<Product> get products => [];

  @override
  Future<void> loadProducts() async {
    // No-op for web
  }

  @override
  Future<void> addProduct(Product product) async {
    // No-op for web
  }

  @override
  Future<void> updateProduct(Product product) async {
    // No-op for web
  }

  @override
  Future<void> deleteProduct(int id) async {
    // No-op for web
  }

  @override
  Product? findById(int id) {
    return null;
  }
}