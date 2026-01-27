import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:pos_app/models/sale_model.dart';
import 'package:pos_app/models/company_model.dart';
import 'package:intl/intl.dart';

class PrinterService {
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getDevices() async {
    return await printer.getBondedDevices();
  }

  Future<void> connect(BluetoothDevice device) async {
    await printer.connect(device);
  }

  Future<void> disconnect() async {
    await printer.disconnect();
  }

  Future<bool?> isConnected() async {
    return await printer.isConnected;
  }

  /// Prints a professional receipt for a Sale
  Future<void> printReceipt(Sale sale, Company company) async {
    bool? connected = await printer.isConnected;
    if (connected != true) return;

    final date =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(sale.createdAt));
    final currency = company.currencySymbol;

    // Header
    printer.printCustom(company.name, 3, 1); // Size 3 (Large), Center align
    if (company.receiptHeader != null && company.receiptHeader!.isNotEmpty) {
      printer.printCustom(company.receiptHeader!, 1, 1);
    }
    if (company.address != null) {
      printer.printCustom(company.address!, 1, 1);
    }
    if (company.phone != null) {
      printer.printCustom("Tel: ${company.phone}", 1, 1);
    }

    printer.printNewLine();
    printer.printCustom(
        "RECEIPT #${sale.id.toUpperCase().substring(sale.id.length - 6)}",
        1,
        1);
    printer.printCustom("Date: $date", 1, 1);
    printer.printCustom("--------------------------------", 1, 1);

    // Items Header
    printer.printLeftRight("ITEM", "TOTAL", 1);
    printer.printCustom("--------------------------------", 1, 1);

    // Items
    for (var item in sale.items) {
      printer.printCustom(item.productName, 1, 0); // Left align
      printer.printLeftRight("${item.quantity} x $currency${item.pricePerUnit}",
          "$currency${item.total}", 1);
    }

    printer.printCustom("--------------------------------", 1, 1);

    // Summary
    printer.printLeftRight(
        "SUBTOTAL", "$currency${sale.totalAmount - sale.vatAmount}", 1);
    printer.printLeftRight("VAT", "$currency${sale.vatAmount}", 1);
    printer.printCustom("TOTAL", 2, 1); // Large
    printer.printCustom("$currency${sale.totalAmount}", 2, 1);

    if (sale.isCredit) {
      printer.printCustom("*** CREDIT SALE ***", 1, 1);
    }

    printer.printNewLine();

    // Footer
    printer.printCustom(company.receiptFooter, 1, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }
}
