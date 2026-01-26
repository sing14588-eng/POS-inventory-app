import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:pos_app/widgets/glass_container.dart';
import 'package:pos_app/models/sale_model.dart';
import 'package:pos_app/services/receipt_service.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppDataProvider>(context, listen: false)
          .fetchMySales(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);
      if (provider.hasMoreSales) {
        provider.fetchMySales(refresh: false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showReceipt(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.receipt_long,
                  size: 48, color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              const Text('Digital Receipt',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                  DateFormat('MMM dd, yyyy HH:mm')
                      .format(DateTime.parse(sale.createdAt)),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const Divider(height: 32),
              ...sale.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                                '${item.productName} (x${item.quantity})',
                                style: const TextStyle(fontSize: 14))),
                        Text('\$${item.total}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('\$${sale.totalAmount}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primaryColor)),
                ],
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ReceiptService.generateAndPrintReceipt(sale);
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                  ),
                  if (sale.refundStatus == 'none')
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRefundDialog(sale.id);
                      },
                      icon: const Icon(Icons.replay, color: Colors.orange),
                      label: const Text('Refund',
                          style: TextStyle(color: Colors.orange)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                          sale.refundStatus == 'requested'
                              ? 'Refund Pending'
                              : 'Refunded',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold)),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showRefundDialog(String saleId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Refund'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason for return'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success =
                  await Provider.of<AppDataProvider>(context, listen: false)
                      .requestRefund(saleId, reasonController.text);

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refund Requested')));
                }
              }
            },
            child: const Text('Submit Request'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sales = Provider.of<AppDataProvider>(context).mySales;

    return Scaffold(
      appBar: AppBar(title: const Text('My Sales History')),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<AppDataProvider>(context, listen: false)
            .fetchMySales(refresh: true),
        child: sales.isEmpty
            ? const Center(child: Text('No sales found'))
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: sales.length +
                    (Provider.of<AppDataProvider>(context).hasMoreSales
                        ? 1
                        : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == sales.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final sale = sales[index];
                  return GestureDetector(
                    onTap: () => _showReceipt(sale),
                    child: GlassContainer(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shopping_bag_outlined,
                                color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Order #${sale.id.substring(sale.id.length - 6).toUpperCase()}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    DateFormat('MMM dd, HH:mm')
                                        .format(DateTime.parse(sale.createdAt)),
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                if (sale.isPrepared)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle,
                                            size: 12, color: Colors.green),
                                        SizedBox(width: 4),
                                        Text('READY',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${sale.totalAmount}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text('${sale.items.length} Items',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
