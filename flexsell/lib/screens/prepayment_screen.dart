import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../providers/sale_provider.dart';

class PrepaymentScreen extends StatefulWidget {
  @override
  _PrepaymentScreenState createState() => _PrepaymentScreenState();
}

class _PrepaymentScreenState extends State<PrepaymentScreen> {
  final TextEditingController amountController = TextEditingController();
  int? selectedCustomerId;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;

    return Scaffold(
      appBar: AppBar(title: Text('Customer Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Select Customer',
                border: OutlineInputBorder(),
              ),
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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleAddBalance,
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Text('Add Funds'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddBalance() async {
    if (selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a customer')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await context.read<SaleProvider>().addFundsToWallet(
            customerId: selectedCustomerId!,
            amount: amount,
          );

      await context.read<CustomerProvider>().loadCustomers();

      final customer = context
          .read<CustomerProvider>()
          .customers
          .firstWhere((c) => c.id == selectedCustomerId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prepayment recorded for ${customer.name}')),
      );

      setState(() {
        amountController.clear();
        selectedCustomerId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add balance: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
