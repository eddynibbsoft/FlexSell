import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';

class StatsProvider extends ChangeNotifier {
  final DatabaseHelper? db;
  
  int _totalSales = 0;
  double _totalRevenue = 0.0;
  int _totalCustomers = 0;
  int _totalProducts = 0;
  
  StatsProvider(this.db) {
    loadStats();
  }
  
  int get totalSales => _totalSales;
  double get totalRevenue => _totalRevenue;
  int get totalCustomers => _totalCustomers;
  int get totalProducts => _totalProducts;
  
  Future<void> loadStats() async {
    try {
      if (db == null) return;
      // Get today's sales
      final sales = await db!.getAllSales();
      final today = DateTime.now();
      final todaySales = sales.where((sale) {
        return sale.date.year == today.year &&
               sale.date.month == today.month &&
               sale.date.day == today.day;
      }).toList();
      
      _totalSales = todaySales.length;
      _totalRevenue = todaySales.fold(0.0, (sum, sale) => sum + sale.amountPaid);
      
      // Get total customers and products
      final customers = await db!.getAllCustomers();
      final products = await db!.getAllProducts();
      
      _totalCustomers = customers.length;
      _totalProducts = products.length;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }
  
  Future<Map<String, dynamic>> getDetailedStats() async {
    try {
      if (db == null) return {};
      final sales = await db!.getAllSales();
      final customers = await db!.getAllCustomers();
      final products = await db!.getAllProducts();
      
      final today = DateTime.now();
      final thisWeek = today.subtract(Duration(days: 7));
      final thisMonth = DateTime(today.year, today.month, 1);
      
      // Today's stats
      final todaySales = sales.where((sale) {
        return sale.date.year == today.year &&
               sale.date.month == today.month &&
               sale.date.day == today.day;
      }).toList();
      
      // This week's stats
      final weekSales = sales.where((sale) => sale.date.isAfter(thisWeek)).toList();
      
      // This month's stats
      final monthSales = sales.where((sale) => sale.date.isAfter(thisMonth)).toList();
      
      // Customer balances
      final creditCustomers = customers.where((c) => c.prepaidBalance < 0).length;
      final prepaidCustomers = customers.where((c) => c.prepaidBalance > 0).length;
      
      return {
        'today': {
          'sales': todaySales.length,
          'revenue': todaySales.fold(0.0, (sum, sale) => sum + sale.amountPaid),
        },
        'week': {
          'sales': weekSales.length,
          'revenue': weekSales.fold(0.0, (sum, sale) => sum + sale.amountPaid),
        },
        'month': {
          'sales': monthSales.length,
          'revenue': monthSales.fold(0.0, (sum, sale) => sum + sale.amountPaid),
        },
        'customers': {
          'total': customers.length,
          'credit': creditCustomers,
          'prepaid': prepaidCustomers,
        },
        'products': {
          'total': products.length,
        },
      };
    } catch (e) {
      debugPrint('Error getting detailed stats: $e');
      return {};
    }
  }
}
