// screens/transaction_history_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../providers/sale_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Map<String, dynamic>> allSales = [];
  int? selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadSales();
  }

  Future<void> loadSales() async {
    final data = await Provider.of<SaleProvider>(context, listen: false).getSalesWithDetails();
    setState(() {
      allSales = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customers = allSales
        .map((s) => {
              'id': s['customerId'],
              'name': s['customerName'] ?? 'Deleted Customer',
            })
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Transaction History'),
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
            tooltip: 'Export PDF',
            onPressed: () => _exportToPDF(allSales),
          ),
          IconButton(
            icon: Icon(Icons.file_download),
            tooltip: 'Export CSV',
            onPressed: () => _exportToCSV(allSales),
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
                  value: selectedCustomerId,
                  hint: Text('Filter by Customer'),
                  items: customers.map((c) {
                    return DropdownMenuItem<int>(
                      value: c['id'],
                      child: Text(c['name']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCustomerId = val;
                    });
                  },
                ),
              ),
              Expanded(
                child: buildTransactionList(
                  allSales.where((s) => selectedCustomerId == null || s['customerId'] == selectedCustomerId).toList(),
                ),
              )
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
        final isCredit = s['paymentType'] == 'Credit';
        final amount = s['amountPaid'] as double;
        final date = DateTime.tryParse(s['date'] ?? '') ?? DateTime.now();

        return ListTile(
          title: Text('${s['productName'] ?? 'Deleted Product'}'),
          subtitle: Text(
              'Customer: ${s['customerName'] ?? 'Deleted Customer'}\nDate: ${date.toLocal().toString().split('.')[0]}'),
          trailing: Text(
            '${isCredit ? '+' : '-'} \$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCredit ? Colors.red : Colors.green,
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportToPDF(List<Map<String, dynamic>> sales) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Wallet Transaction History', style: pw.TextStyle(fontSize: 20)),
          ),
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

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
      SnackBar(content: Text('CSV file saved to ${file.path}')),
    );
  }
}
