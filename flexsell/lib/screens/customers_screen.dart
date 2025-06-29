import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customer_provider.dart';
import '../widgets/customer_form.dart';

class CustomersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final customers = customerProvider.customers;

    return Scaffold(
      appBar: AppBar(title: Text('Customers')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (_, index) {
                final customer = customers[index];
                return ListTile(
                  title: Text(customer.name),
                  subtitle: Text('Phone: ${customer.phone}'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Prepaid: \$${customer.prepaidBalance.toStringAsFixed(2)}'),
                      Text('Credit: \$${customer.creditOwed.toStringAsFixed(2)}'),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomerForm(),
          ),
        ],
      ),
    );
  }
}
