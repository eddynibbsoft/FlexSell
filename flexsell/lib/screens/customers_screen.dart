import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customer_provider.dart';
import '../widgets/customer_form.dart';
import '../models/customer.dart';
import '../utils/pdf_receipt.dart';

class CustomersScreen extends StatefulWidget {
  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final allCustomers = customerProvider.customers;

    List<Customer> filteredCustomers = allCustomers.where((customer) {
      final lowerQuery = searchQuery.toLowerCase();
      return customer.name.toLowerCase().contains(lowerQuery) ||
             customer.phone.toLowerCase().contains(lowerQuery);
    }).toList();

    List<Customer> allTabCustomers = filteredCustomers;

    List<Customer> creditTabCustomers = filteredCustomers
        .where((c) => c.prepaidBalance < 0)
        .toList();

    List<Customer> prepaidTabCustomers = filteredCustomers
        .where((c) => c.prepaidBalance > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Credit'),
            Tab(text: 'Prepaid'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                customerListView(context, allTabCustomers),
                customerListView(context, creditTabCustomers),
                customerListView(context, prepaidTabCustomers),
              ],
            ),
          ),
        ],
      ),

      // FAB to add customer
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add Customer',
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Add Customer'),
              content: CustomerForm(),
            ),
          );
        },
      ),
    );
  }

  Widget customerListView(BuildContext context, List<Customer> customers) {
    if (customers.isEmpty) {
      return Center(child: Text('No customers found.'));
    }

    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (_, index) {
        final customer = customers[index];
        return ListTile(
          title: Text(customer.name),
          subtitle: Text('Phone: ${customer.phone}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Prepaid: \$${customer.prepaidBalance.toStringAsFixed(2)}'),
        
                ],
              ),
              IconButton(
                icon: Icon(Icons.picture_as_pdf, color: Colors.green),
                tooltip: 'Print Receipt',
                onPressed: () => printCustomerReceipt(customer),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Edit Customer'),
                      content: CustomerForm(customer: customer),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => confirmDeleteCustomer(context, customer),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> confirmDeleteCustomer(BuildContext context, Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<CustomerProvider>().deleteCustomer(customer.id!);
    }
  }
}
