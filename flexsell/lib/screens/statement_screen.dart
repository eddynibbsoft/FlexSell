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
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Map<String, dynamic>> allSales = [];
  int? selectedCustomerId;
  String? statementSummary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadSales();
  }

  Future<void> loadSales() async {
  final sales = await context.read<SaleProvider>().getSalesWithDetails();
  if (!mounted) return;
  setState(() {
    allSales = sales;
  });
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
      SnackBar(content: Text('CSV saved to ${file.path}')),
    );
  }

  Future<void> _exportToPDF(List<Map<String, dynamic>> sales) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
              level: 0,
              child: pw.Text('Wallet Transaction History',
                  style: pw.TextStyle(fontSize: 20))),
          pw.Table.fromTextArray(
            headers: ['Date', 'Customer', 'Product', 'Type', 'Amount'],
            data: sales.map((s) {
              final date = DateTime.tryParse(s['date'] ?? '')?.toLocal().toString().split('.')[0] ?? '';
              return [
                date,
                s['customerName'] ?? 'Deleted Customer',
                s['productName'] ?? 'Deleted Product',
                s['paymentType'],
                s['amountPaid'].toStringAsFixed(2),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final customerMap = <int, String>{};

    for (var s in allSales) {
      final id = s['customerId'];
      final name = s['customerName'] ?? 'Deleted Customer';
      if (id != null) {
        customerMap[id] = name;
      }
    }

    final customers = customerMap.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList();


    final filteredSales = selectedCustomerId == null
        ? allSales
        : allSales.where((s) => s['customerId'] == selectedCustomerId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Statement'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Transactions'),
            Tab(text: 'By Customer'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPDF(filteredSales),
          ),
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () => _exportToCSV(filteredSales),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTransactionList(allSales),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: Text('Select Customer'),
                  value: selectedCustomerId,
                  items: customers.map((c) {
                    return DropdownMenuItem<int>(
                      value: c['id'] as int?,
                      child: Text(c['name'] as String),
                    );
                  }).toList(),

                  onChanged: (val) {
                    setState(() {
                      selectedCustomerId = val;
                      if (val != null) {
                        final summary = context
                            .read<SaleProvider>()
                            .getCustomerStatement(val);
                        statementSummary = summary;
                      } else {
                        statementSummary = null;
                      }
                    });
                  },
                ),
              ),
              if (statementSummary != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: Colors.indigo[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        statementSummary!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              Expanded(child: buildTransactionList(filteredSales)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTransactionList(List<Map<String, dynamic>> sales) {
    if (sales.isEmpty) {
      return Center(child: Text('No transactions available.'));
    }

    return ListView.builder(
      itemCount: sales.length,
      itemBuilder: (_, index) {
        final s = sales[index];
        final amount = s['amountPaid'] as double;
        final date = DateTime.tryParse(s['date'] ?? '') ?? DateTime.now();

        return ListTile(
          title: Text('${s['productName'] ?? 'Deleted Product'}'),
          subtitle: Text(
              'Customer: ${s['customerName'] ?? 'Deleted Customer'}\nDate: ${date.toLocal().toString().split('.')[0]}'),
          trailing: Text(
            (amount < 0 ? '- ' : '+ ') + '\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: amount < 0 ? Colors.red : Colors.green,
            ),
          ),
        );
      },
    );
  }
}
