// widgets/sale_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sale.dart';
import '../providers/sale_provider.dart';
// Add missing imports at the top of sale_form.dart
import '../providers/product_provider.dart';
import '../providers/customer_provider.dart';

class SaleForm extends StatefulWidget {
  @override
  _SaleFormState createState() => _SaleFormState();
}

class _SaleFormState extends State<SaleForm> {
  String? selectedProductId;
  String? selectedCustomerId;
  String paymentType = 'Cash';

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final customers = context.watch<CustomerProvider>().customers;

    return Column(
      children: [
        DropdownButton<String>(
          hint: Text('Select Product'),
          value: selectedProductId,
          onChanged: (value) => setState(() => selectedProductId = value),
          items: products.map((p) => DropdownMenuItem(value: p.id.toString(), child: Text(p.name))).toList(),
        ),
        DropdownButton<String>(
          hint: Text('Select Customer'),
          value: selectedCustomerId,
          onChanged: (value) => setState(() => selectedCustomerId = value),
          items: customers.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name))).toList(),
        ),
        DropdownButton<String>(
          value: paymentType,
          onChanged: (value) => setState(() => paymentType = value!),
          items: ['Cash', 'Credit'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<SaleProvider>().createSale(
              productId: int.parse(selectedProductId!),
              customerId: int.parse(selectedCustomerId!),
              paymentType: paymentType,
            );
          },
          child: Text('Record Sale'),
        )
      ],
    );
  }
}
