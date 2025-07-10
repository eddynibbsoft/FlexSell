import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer; // null for add, non-null for edit

  CustomerForm({this.customer});

  @override
  _CustomerFormState createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  late TextEditingController nameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.customer?.name ?? '');
    phoneController = TextEditingController(text: widget.customer?.phone ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void submit() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a customer name')),
      );
      return;
    }

    final customerProvider = context.read<CustomerProvider>();

    if (widget.customer == null) {
      // Add new customer
      final newCustomer = Customer(
        name: name,
        phone: phone,
        prepaidBalance: 0,

      );
      await customerProvider.addCustomer(newCustomer);
    } else {
      // Update existing customer
      final updatedCustomer = Customer(
        id: widget.customer!.id,
        name: name,
        phone: phone,
        prepaidBalance: widget.customer!.prepaidBalance,
       
      );
      await customerProvider.updateCustomer(updatedCustomer);
    }

    Navigator.of(context).pop(); // Close dialog after submit
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Customer Name'),
          ),
          SizedBox(height: 8),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: submit,
            child: Text(isEdit ? 'Update Customer' : 'Add Customer'),
          )
        ],
      ),
    );
  }
}
