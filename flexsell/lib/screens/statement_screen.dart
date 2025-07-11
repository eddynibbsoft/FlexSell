import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../providers/sale_provider.dart';
import '../providers/customer_provider.dart';

class StatementScreen extends StatefulWidget {
  @override
  _StatementScreenState createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> allSales = [];
  List<Map<String, dynamic>> filteredSales = [];
  List<Map<String, dynamic>> customers = [];
  String searchQuery = '';
  int? selectedCustomerId;
  String? statementSummary;
  bool isGrouped = false;

  DateTime? startDate;
  DateTime? endDate;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    loadSales();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadSales() async {
    final sales = await context.read<SaleProvider>().getSalesWithDetails();
    final customerMap = <int, String>{};

    for (var s in sales) {
      final id = s['customerId'];
      final name = s['customerName'] ?? 'Deleted Customer';
      if (id != null) {
        customerMap[id] = name;
      }
    }

    setState(() {
      allSales = sales;
      customers = [
        {'id': null, 'name': 'All Customers'},
        ...customerMap.entries.map((e) => {'id': e.key, 'name': e.value})
      ];
    });

    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> sales = allSales;

    if (selectedCustomerId != null) {
      sales = sales.where((s) => s['customerId'] == selectedCustomerId).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      sales = sales.where((s) {
        final cust = (s['customerName'] ?? '').toString().toLowerCase();
        final prod = (s['productName'] ?? '').toString().toLowerCase();
        return cust.contains(q) || prod.contains(q);
      }).toList();
    }

    if (startDate != null) {
      sales = sales.where((s) {
        final date = DateTime.tryParse(s['date'] ?? '');
        if (date == null) return false;
        return !date.isBefore(startDate!);
      }).toList();
    }
    if (endDate != null) {
      sales = sales.where((s) {
        final date = DateTime.tryParse(s['date'] ?? '');
        if (date == null) return false;
        return !date.isAfter(endDate!);
      }).toList();
    }

    setState(() {
      filteredSales = sales;

      if (selectedCustomerId != null) {
        final summary =
            context.read<SaleProvider>().getCustomerStatement(selectedCustomerId!);
        statementSummary = summary;
      } else {
        statementSummary = null;
      }
    });
  }

  void _resetFilters() {
    setState(() {
      selectedCustomerId = null;
      searchQuery = '';
      isGrouped = false;
      startDate = null;
      endDate = null;
    });
    _applyFilters();
  }

  Future<void> _exportToCSV(List<Map<String, dynamic>> sales) async {
    final rows = <List<String>>[];
    rows.add(['Date', 'Customer', 'Product', 'Type', 'Amount']);

    for (var s in sales) {
      final date = DateTime.tryParse(s['date'] ?? '')?.toLocal().toString().split('.')[0] ?? '';
      rows.add([
        date,
        s['customerName'] ?? 'Deleted Customer',
        s['productName'] ?? 'Deleted Product',
        s['paymentType'],
        s['amountPaid'].toStringAsFixed(2),
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/transaction_history.csv');
    await file.writeAsString(csvData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV saved to ${file.path}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _exportToPDF(List<Map<String, dynamic>> sales) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
              level: 0,
              child: pw.Text('Transaction History Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Date', 'Customer', 'Product', 'Type', 'Amount'],
            data: sales.map((s) {
              final date = DateTime.tryParse(s['date'] ?? '')?.toLocal().toString().split('.')[0] ?? '';
              return [
                date,
                s['customerName'] ?? 'Deleted Customer',
                s['productName'] ?? 'Deleted Product',
                s['paymentType'],
                '\$${s['amountPaid'].toStringAsFixed(2)}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now().subtract(Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
      _applyFilters();
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final filteredCustomerOptions = customers
        .where((c) => c['name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_rounded),
            onPressed: () => _exportToPDF(filteredSales),
            tooltip: 'Export to PDF',
          ),
          IconButton(
            icon: Icon(Icons.file_download_rounded),
            onPressed: () => _exportToCSV(filteredSales),
            tooltip: 'Export to CSV',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded),
                    SizedBox(width: 8),
                    Text('Refresh Data'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics_rounded),
                    SizedBox(width: 8),
                    Text('View Analytics'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Enhanced Filter Section
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
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Customer or Product',
                      prefixIcon: Icon(Icons.search_rounded),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                                _applyFilters();
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                      _applyFilters();
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Customer Filter
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Filter by Customer',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    isExpanded: true,
                    value: selectedCustomerId,
                    items: filteredCustomerOptions.map((c) {
                      return DropdownMenuItem<int>(
                        value: c['id'],
                        child: Text(c['name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCustomerId = val;
                      });
                      _applyFilters();
                    },
                  ),
                  SizedBox(height: 16),

                  // Date Range Filters
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickStartDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              prefixIcon: Icon(Icons.calendar_today_rounded),
                            ),
                            child: Text(
                              startDate == null
                                  ? 'Select start date'
                                  : startDate!.toLocal().toString().split(' ')[0],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _pickEndDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              prefixIcon: Icon(Icons.event_rounded),
                            ),
                            child: Text(
                              endDate == null
                                  ? 'Select end date'
                                  : endDate!.toLocal().toString().split(' ')[0],
                            ),
                          ),
                        ),
                      ),
                      if (startDate != null || endDate != null)
                        IconButton(
                          icon: Icon(Icons.clear_rounded),
                          tooltip: 'Clear dates',
                          onPressed: () {
                            setState(() {
                              startDate = null;
                              endDate = null;
                            });
                            _applyFilters();
                          },
                        ),
                    ],
                  ),

                  SizedBox(height: 16),
                  
                  // Controls Row
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.group_work_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Group by product',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Spacer(),
                            Switch(
                              value: isGrouped,
                              onChanged: (value) {
                                setState(() {
                                  isGrouped = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _resetFilters,
                        icon: Icon(Icons.refresh_rounded, size: 18),
                        label: Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Summary Card
                  if (statementSummary != null)
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.1),
                            colorScheme.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.analytics_rounded,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              statementSummary!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Results Count
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    '${filteredSales.length} transactions found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1),
            
            // Transaction List
            Expanded(
              child: isGrouped
                  ? _buildGroupedTransactionList(filteredSales)
                  : _buildFlatTransactionList(filteredSales),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatTransactionList(List<Map<String, dynamic>> sales) {
    if (sales.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildTransactionCard(sales[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final amount = transaction['amountPaid'] as double;
    final date = DateTime.tryParse(transaction['date'] ?? '') ?? DateTime.now();
    final isCredit = amount < 0;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Transaction Icon
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCredit
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isCredit ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['productName'] ?? 'Deleted Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    transaction['customerName'] ?? 'Deleted Customer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date.toLocal().toString().split('.')[0],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (amount < 0 ? '-' : '+') + '\$${amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.red : Colors.green,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction['paymentType'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedTransactionList(List<Map<String, dynamic>> sales) {
    if (sales.isEmpty) {
      return _buildEmptyState();
    }

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var s in sales) {
      final product = s['productName'] ?? 'Unknown Product';
      grouped.putIfAbsent(product, () => []).add(s);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final totalAmount = entry.value.fold<double>(
          0.0,
          (sum, transaction) => sum + (transaction['amountPaid'] as double),
        );

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      entry.key,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${entry.value.length} transactions'),
                    trailing: Text(
                      '\$${totalAmount.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: totalAmount < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                    children: entry.value.map((transaction) {
                      final amount = transaction['amountPaid'] as double;
                      final date = DateTime.tryParse(transaction['date'] ?? '') ?? DateTime.now();
                      
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                        title: Text(transaction['customerName'] ?? 'Deleted Customer'),
                        subtitle: Text(date.toLocal().toString().split('.')[0]),
                        trailing: Text(
                          '\$${amount.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: amount < 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
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
              Icons.receipt_long_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Transactions Found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add some transactions',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _resetFilters,
            icon: Icon(Icons.refresh_rounded),
            label: Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'refresh':
        loadSales();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data refreshed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'analytics':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analytics feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }
}
