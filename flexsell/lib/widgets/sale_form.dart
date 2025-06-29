// widgets/sale_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sale.dart';
import '../providers/sale_provider.dart';
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
          value: products.any((p) => p.id.toString() == selectedProductId)
              ? selectedProductId
              : null,
          onChanged: (value) => setState(() => selectedProductId = value),
          items: products
              .map((p) => DropdownMenuItem<String>(
                    value: p.id.toString(),
                    child: Text(p.name),
                  ))
              .toList(),
        ),
        DropdownButton<String>(
          hint: Text('Select Customer'),
          value: customers.any((c) => c.id.toString() == selectedCustomerId)
              ? selectedCustomerId
              : null,
          onChanged: (value) => setState(() => selectedCustomerId = value),
          items: customers
              .map((c) => DropdownMenuItem<String>(
                    value: c.id.toString(),
                    child: Text(c.name),
                  ))
              .toList(),
        ),
        DropdownButton<String>(
          value: paymentType,
          onChanged: (value) => setState(() => paymentType = value!),
          items: ['Cash', 'Credit']
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
        ),
        ElevatedButton(
  onPressed: () async {
    if (selectedProductId == null || selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both a product and a customer.')),
      );
      return;
    }

    try {
      await context.read<SaleProvider>().createSale(
        productId: int.parse(selectedProductId!),
        customerId: int.parse(selectedCustomerId!),
        paymentType: paymentType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale recorded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record sale: $e')),
      );
    }
  },
  child: Text('Record Sale'),
)

      ],
    );
  }
}
