import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../providers/sale_provider.dart';
import '../models/customer.dart';

class StatementScreen extends StatefulWidget {
  @override
  _StatementScreenState createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  Customer? selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;

    return Scaffold(
      appBar: AppBar(title: Text('Customer Statement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<Customer>(
              isExpanded: true,
              hint: Text('Select Customer'),
              value: selectedCustomer,
              onChanged: (Customer? c) {
                setState(() {
                  selectedCustomer = c;
                });
              },
              items: customers.map((c) {
                return DropdownMenuItem<Customer>(
                  value: c,
                  child: Text(c.name),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedCustomer != null) {
                  final summary = context
                      .read<SaleProvider>()
                      .getCustomerStatement(selectedCustomer!.id!);

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Statement for ${selectedCustomer!.name}'),
                      content: Text(summary),
                      actions: [
                        TextButton(
                          child: Text("Close"),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    ),
                  );
                }
              },
              child: Text('Generate Statement'),
            )
          ],
        ),
      ),
    );
  }
}
