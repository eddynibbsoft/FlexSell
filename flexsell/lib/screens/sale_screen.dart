import 'package:flutter/material.dart';
import '../widgets/sale_form.dart';

class SaleScreen extends StatelessWidget {
  const SaleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EnhancedSaleForm(),
      ),
    );
  }
}
