import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/customer.dart';

Future<void> printCustomerReceipt(Customer customer) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(16),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('FlexSell Wallet',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Text('Name: ${customer.name}'),
            pw.Text('Phone: ${customer.phone}'),
            pw.SizedBox(height: 12),
            pw.Text('Balance: \$${customer.prepaidBalance.toStringAsFixed(2)}'),
 
            pw.Divider(),
            pw.Text('Thank you for supporting us!'),
          ],
        ),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
