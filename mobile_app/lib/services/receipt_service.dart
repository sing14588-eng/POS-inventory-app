import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos_app/models/sale_model.dart';
import 'package:intl/intl.dart';

class ReceiptService {
  static Future<void> generateAndPrintReceipt(Sale sale) async {
    final pdf = pw.Document();
    final DateTime createdAt =
        DateTime.tryParse(sale.createdAt) ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Standard receipt width
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('POS INVENTORY APP',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(child: pw.Text('Order Receipt')),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Date: $dateStr'),
              pw.Text(
                  'Order ID: ${sale.id.substring(sale.id.length > 8 ? sale.id.length - 8 : 0)}'),
              pw.SizedBox(height: 10),
              pw.Table(
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Item',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...sale.items.map((item) => pw.TableRow(
                        children: [
                          pw.Text(item.productName),
                          pw.Text('${item.quantity}'),
                          pw.Text('${item.total}'),
                        ],
                      )),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Amount:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${sale.totalAmount}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (sale.isCredit)
                pw.Center(child: pw.Text('*** CREDIT SALE ***')),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Thank you for your business!')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
