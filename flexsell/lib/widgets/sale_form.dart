// widgets/sale_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../models/product.dart';
import '../providers/customer_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';

class SaleForm extends StatefulWidget {
  @override
  _SaleFormState createState() => _SaleFormState();
}

class _SaleFormState extends State<SaleForm> {
  int? selectedCustomerId;
  int? selectedProductId;

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    final products = context.watch<ProductProvider>().products;

    final screenWidth = MediaQuery.of(context).size.width;
    const maxWidth = 400.0;
    double horizontalPadding = 16;
    if (screenWidth > maxWidth) {
      horizontalPadding = (screenWidth - maxWidth) / 2;
    }

    double labelFontSize = 16;
    double buttonFontSize = 16;
    if (screenWidth > 600) {
      labelFontSize = 18;
      buttonFontSize = 18;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: selectedCustomerId,
              hint: Text('Select Customer'),
              decoration: InputDecoration(
                labelText: 'Customer',
                labelStyle: TextStyle(fontSize: labelFontSize),
                border: OutlineInputBorder(),
              ),
              items: customers.map((customer) {
                return DropdownMenuItem<int>(
                  value: customer.id,
                  child: Text(
                    '${customer.name} (Wallet: \$${customer.prepaidBalance.toStringAsFixed(2)})',
                    style: TextStyle(fontSize: labelFontSize),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedCustomerId = val;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedProductId,
              hint: Text('Select Product'),
              decoration: InputDecoration(
                labelText: 'Product',
                labelStyle: TextStyle(fontSize: labelFontSize),
                border: OutlineInputBorder(),
              ),
              items: products.map((product) {
                return DropdownMenuItem<int>(
                  value: product.id,
                  child: Text(
                    '${product.name} (Cash: \$${product.cashPrice}, Credit: \$${product.creditPrice})',
                    style: TextStyle(fontSize: labelFontSize),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedProductId = val;
                });
              },
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: Icon(Icons.check_circle_outline),
                label: Text(
                  'Complete Sale',
                  style: TextStyle(fontSize: buttonFontSize),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (selectedCustomerId == null || selectedProductId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select both customer and product')),
                    );
                    return;
                  }

                  await context.read<SaleProvider>().createSale(
                        customerId: selectedCustomerId!,
                        productId: selectedProductId!,
                      );

                  await context.read<CustomerProvider>().loadCustomers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sale recorded successfully')),
                  );

                  setState(() {
                    selectedCustomerId = null;
                    selectedProductId = null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
