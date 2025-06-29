
// screens/prepayment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // <-- Add this
import '../models/customer.dart';
import '../providers/customer_provider.dart';

class PrepaymentScreen extends StatefulWidget {
  @override
  _PrepaymentScreenState createState() => _PrepaymentScreenState();
}

class _PrepaymentScreenState extends State<PrepaymentScreen> {
  final TextEditingController amountController = TextEditingController();
  Customer? selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;

    return Scaffold(
      appBar: AppBar(title: Text('Add Prepayment')),
      body: Column(
        children: [
          DropdownButton<Customer>(
            hint: Text('Select Customer'),
            value: selectedCustomer,
            onChanged: (c) {
              setState(() {
                selectedCustomer = c;
              });
            },
            items: customers
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
          ),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedCustomer != null && amountController.text.isNotEmpty) {
                final amount = double.tryParse(amountController.text) ?? 0;
                selectedCustomer!.prepaidBalance += amount;
                await context.read<CustomerProvider>().updateCustomer(selectedCustomer!);
              }
            },
            child: Text('Add Balance'),
          ),
        ],
      ),
    );
  }
}
