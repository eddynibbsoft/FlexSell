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
    final screenWidth = MediaQuery.of(context).size.width;

    // Max content width for tablet/desktop
    const maxContentWidth = 600.0;

    // Horizontal padding to center content on wide screens
    double horizontalPadding = 16;
    if (screenWidth > maxContentWidth) {
      horizontalPadding = (screenWidth - maxContentWidth) / 2;
    }

    // Scale font size a bit for bigger screens
    double headerFontSize = 22;
    if (screenWidth > 800) {
      headerFontSize = 28;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Customer Wallet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal[600]!, Colors.teal[400]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.teal[100]!, Colors.teal[50]!],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.teal[700],
                              size: 36,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'FlexSell Wallet',
                            style: TextStyle(
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Top-up a customer\'s wallet balance',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Card(
                    elevation: 6,
                    shadowColor: Colors.teal.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form Title
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.teal[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    Icon(Icons.attach_money, color: Colors.teal[700]),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Top Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Customer Dropdown
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Select Customer',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedCustomerId,
                            onChanged: (id) {
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

                          // Amount Input
                          TextField(
                            controller: amountController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _handleAddBalance,
                              icon: isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.save),
                              label: Text(isLoading ? 'Processing...' : 'Add Funds'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[600],
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
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

    setState(() => isLoading = true);

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
        SnackBar(content: Text('Wallet Topped Up for ${customer.name}')),
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
      setState(() => isLoading = false);
    }
  }
}
