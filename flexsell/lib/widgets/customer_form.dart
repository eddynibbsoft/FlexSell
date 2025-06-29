
// widgets/customer_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';

class CustomerForm extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: nameController, decoration: InputDecoration(labelText: 'Customer Name')),
        TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
        ElevatedButton(
          onPressed: () {
            final customer = Customer(
              name: nameController.text,
              phone: phoneController.text,
              prepaidBalance: 0,
              creditOwed: 0,
            );
            context.read<CustomerProvider>().addCustomer(customer);
          },
          child: Text('Add Customer'),
        )
      ],
    );
  }
}
