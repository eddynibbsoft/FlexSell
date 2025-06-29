import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/database_helper.dart';

import 'providers/product_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/sale_provider.dart';
import 'screens/home_screen.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // 👈 Add this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize ffi for desktop platforms
  sqfliteFfiInit(); // 👈 Required
  databaseFactory = databaseFactoryFfi; // 👈 This is the key line

  final dbHelper = DatabaseHelper.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => CustomerProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => SaleProvider(dbHelper)),
      ],
      child: MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
}
