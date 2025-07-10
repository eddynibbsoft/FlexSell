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

    Customer? selectedCustomer = selectedCustomerId != null
        ? customers.firstWhere((c) => c.id == selectedCustomerId, orElse: () => Customer(id: 0, name: '', phone: '', prepaidBalance: 0,))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Dropdown
        DropdownButtonFormField<int>(
          value: selectedCustomerId,
          hint: Text('Select Customer'),
          decoration: InputDecoration(
            labelText: 'Customer',
            border: OutlineInputBorder(),
          ),
          items: customers.map((customer) {
            return DropdownMenuItem(
              value: customer.id,
              child: Text('${customer.name} (Wallet: \$${customer.prepaidBalance.toStringAsFixed(2)})'),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              selectedCustomerId = val;
            });
          },
        ),
        SizedBox(height: 16),

        // Product Dropdown
        DropdownButtonFormField<int>(
          value: selectedProductId,
          hint: Text('Select Product'),
          decoration: InputDecoration(
            labelText: 'Product',
            border: OutlineInputBorder(),
          ),
          items: products.map((product) {
            return DropdownMenuItem(
              value: product.id,
              child: Text('${product.name} (Cash: \$${product.cashPrice}, Credit: \$${product.creditPrice})'),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              selectedProductId = val;
            });
          },
        ),
        SizedBox(height: 24),

        // Confirm Sale Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.check_circle_outline),
            label: Text('Complete Sale'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}
