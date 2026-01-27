import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos_app/models/sale_model.dart';
import 'package:intl/intl.dart';

import 'package:pos_app/models/company_model.dart';

class ReceiptService {
  static Future<void> generateAndPrintReceipt(
      Sale sale, Company company) async {
    final pdf = pw.Document();
    final DateTime createdAt =
        DateTime.tryParse(sale.createdAt) ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(company.name.toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              if (company.receiptHeader != null &&
                  company.receiptHeader!.isNotEmpty)
                pw.Center(
                  child: pw.Text(company.receiptHeader!,
                      style: const pw.TextStyle(fontSize: 10)),
                ),
              if (company.address != null)
                pw.Center(
                  child: pw.Text(company.address!,
                      style: const pw.TextStyle(fontSize: 10)),
                ),
              pw.SizedBox(height: 5),
              pw.Center(
                  child: pw.Text('Order Receipt',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Text('Date: $dateStr',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text(
                  'Order ID: ${sale.id.toUpperCase().substring(sale.id.length - 8)}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 10),
              pw.Table(
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Item',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Qty',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Total',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...sale.items.map((item) => pw.TableRow(
                        children: [
                          pw.Text(item.productName,
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('${item.quantity}',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('${company.currencySymbol}${item.total}',
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      )),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Amount:',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${company.currencySymbol}${sale.totalAmount}',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (sale.isCredit)
                pw.Center(
                    child: pw.Text('*** CREDIT SALE ***',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Text(company.receiptFooter,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 10)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
