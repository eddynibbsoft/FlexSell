import 'package:flutter/material.dart';
import 'package:flexsell/providers/stats_provider.dart';
import '../db/database_helper.dart';

class DummyStatsProvider extends ChangeNotifier implements StatsProvider {
  @override
  final DatabaseHelper? db;

  DummyStatsProvider() : db = null; // Dummy db for web

  @override
  int get totalSales => 0;

  @override
  double get totalRevenue => 0.0;

  @override
  int get totalCustomers => 0;

  @override
  int get totalProducts => 0;

  @override
  Future<void> loadStats() async {
    // No-op for web
  }

  @override
  Future<Map<String, dynamic>> getDetailedStats() async {
    return {}; // No-op for web
  }
}