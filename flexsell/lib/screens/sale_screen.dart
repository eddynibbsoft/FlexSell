import 'package:flutter/material.dart';
import '../widgets/sale_form.dart';

class SaleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record Sale')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SaleForm(),
      ),
    );
  }
}
