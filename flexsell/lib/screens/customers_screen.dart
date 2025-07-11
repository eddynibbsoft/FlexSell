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

class _CustomersScreenState extends State<CustomersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final allCustomers = customerProvider.customers;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    List<Customer> filteredCustomers = allCustomers.where((customer) {
      final lowerQuery = searchQuery.toLowerCase();
      return customer.name.toLowerCase().contains(lowerQuery) ||
             customer.phone.toLowerCase().contains(lowerQuery);
    }).toList();

    List<Customer> creditTabCustomers = filteredCustomers.where((c) => c.prepaidBalance < 0).toList();
    List<Customer> prepaidTabCustomers = filteredCustomers.where((c) => c.prepaidBalance > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download_rounded),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload_rounded),
                    SizedBox(width: 8),
                    Text('Import Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('All'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Credit'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Prepaid'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Enhanced Search Box
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search customers...',
                prefixIcon: Icon(Icons.search_rounded),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Stats Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildStatChip('Total', allCustomers.length, Colors.blue),
                SizedBox(width: 12),
                _buildStatChip('Credit', creditTabCustomers.length, Colors.red),
                SizedBox(width: 12),
                _buildStatChip('Prepaid', prepaidTabCustomers.length, Colors.green),
              ],
            ),
          ),

          // Tabs Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCustomerListView(filteredCustomers),
                _buildCustomerListView(creditTabCustomers),
                _buildCustomerListView(prepaidTabCustomers),
              ],
            ),
          ),
        ],
      ),

      // Enhanced FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerDialog(context),
        icon: Icon(Icons.person_add_rounded),
        label: Text('Add Customer'),
        tooltip: 'Add New Customer',
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          SizedBox(width: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerListView(List<Customer> customers) {
    if (customers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildCustomerCard(customers[index], index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Customers Found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Add your first customer to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCustomerDialog(context),
            icon: Icon(Icons.person_add_rounded),
            label: Text('Add Customer'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCredit = customer.prepaidBalance < 0;
    final isPrepaid = customer.prepaidBalance > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showCustomerDetails(context, customer),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Hero(
                tag: 'customer_${customer.id}',
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCredit
                          ? [Colors.red[400]!, Colors.red[600]!]
                          : isPrepaid
                              ? [Colors.green[400]!, Colors.green[600]!]
                              : [Colors.grey[400]!, Colors.grey[600]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 16),
              
              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_rounded, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          customer.phone.isEmpty ? 'No phone' : customer.phone,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? Colors.red.withOpacity(0.1)
                            : isPrepaid
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Balance: \$${customer.prepaidBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isCredit
                              ? Colors.red[700]
                              : isPrepaid
                                  ? Colors.green[700]
                                  : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleCustomerAction(context, value, customer),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'receipt',
                    child: Row(
                      children: [
                        Icon(Icons.receipt_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Print Receipt'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Search Customers'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: 'Enter name or phone',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCustomerDialog(BuildContext context, {Customer? customer}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                customer == null ? 'Add Customer' : 'Edit Customer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              CustomerForm(customer: customer),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Hero(
              tag: 'customer_${customer.id}',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: customer.prepaidBalance < 0
                        ? [Colors.red[400]!, Colors.red[600]!]
                        : customer.prepaidBalance > 0
                            ? [Colors.green[400]!, Colors.green[600]!]
                            : [Colors.grey[400]!, Colors.grey[600]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              customer.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              customer.phone.isEmpty ? 'No phone number' : customer.phone,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: customer.prepaidBalance < 0
                    ? Colors.red.withOpacity(0.1)
                    : customer.prepaidBalance > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: customer.prepaidBalance < 0
                        ? Colors.red[700]
                        : customer.prepaidBalance > 0
                            ? Colors.green[700]
                            : Colors.grey[700],
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Balance: \$${customer.prepaidBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: customer.prepaidBalance < 0
                          ? Colors.red[700]
                          : customer.prepaidBalance > 0
                              ? Colors.green[700]
                              : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCustomerDialog(context, customer: customer);
                    },
                    icon: Icon(Icons.edit_rounded),
                    label: Text('Edit'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => printCustomerReceipt(customer),
                    icon: Icon(Icons.receipt_rounded),
                    label: Text('Receipt'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'import':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  void _handleCustomerAction(BuildContext context, String action, Customer customer) {
    switch (action) {
      case 'view':
        _showCustomerDetails(context, customer);
        break;
      case 'edit':
        _showCustomerDialog(context, customer: customer);
        break;
      case 'receipt':
        printCustomerReceipt(customer);
        break;
      case 'delete':
        _confirmDeleteCustomer(context, customer);
        break;
    }
  }

  Future<void> _confirmDeleteCustomer(BuildContext context, Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Customer'),
          ],
        ),
        content: Text('Are you sure you want to delete ${customer.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await context.read<CustomerProvider>().deleteCustomer(customer.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${customer.name} deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
