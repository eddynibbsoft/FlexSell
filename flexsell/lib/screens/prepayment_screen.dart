import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';

class PrepaymentScreen extends StatefulWidget {
  @override
  _PrepaymentScreenState createState() => _PrepaymentScreenState();
}

class _PrepaymentScreenState extends State<PrepaymentScreen> {
  final TextEditingController amountController = TextEditingController();
  int? selectedCustomerId;

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;

    return Scaffold(
      appBar: AppBar(title: Text('Add Prepayment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<int>(
              hint: Text('Select Customer'),
              value: selectedCustomerId,
              onChanged: (int? id) {
                setState(() {
                  selectedCustomerId = id;
                });
              },
              items: customers
                  .map((c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (selectedCustomerId != null && amountController.text.isNotEmpty) {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Enter a valid amount')),
                    );
                    return;
                  }

                  final customer = customers.firstWhere((c) => c.id == selectedCustomerId);
                  customer.prepaidBalance += amount;

                  await context.read<CustomerProvider>().updateCustomer(customer);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Prepayment recorded for ${customer.name}')),
                  );

                  setState(() {
                    amountController.clear();
                    selectedCustomerId = null;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a customer and enter amount')),
                  );
                }
              },
              child: Text('Add Balance'),
            ),
          ],
        ),
      ),
    );
  }
}
