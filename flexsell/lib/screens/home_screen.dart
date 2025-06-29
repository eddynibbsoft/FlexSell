
// screens/home_screen.dart
import 'package:flutter/material.dart';    // For Scaffold, AppBar, Navigator, etc.
import 'products_screen.dart';              // Your screen files relative import
import 'customers_screen.dart';
import 'sale_screen.dart';
import 'prepayment_screen.dart';
import 'statement_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seller Dashboard')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Manage Products'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsScreen())),
          ),
          ListTile(
            title: Text('Manage Customers'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomersScreen())),
          ),
          ListTile(
            title: Text('Record Sale'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SaleScreen())),
          ),
          ListTile(
            title: Text('Prepayment'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrepaymentScreen())),
          ),
          ListTile(
            title: Text('Customer Statement'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StatementScreen())),
          ),
        ],
      ),
    );
  }
}