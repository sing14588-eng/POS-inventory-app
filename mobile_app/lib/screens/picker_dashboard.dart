import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
// import 'package:pos_app/utils/app_theme.dart'; // Removed unused import

class PickerDashboard extends StatefulWidget {
  const PickerDashboard({super.key});

  @override
  State<PickerDashboard> createState() => _PickerDashboardState();
}

class _PickerDashboardState extends State<PickerDashboard> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppDataProvider>(context, listen: false)
            .fetchPickerOrders();
      }
    });
  }

  void _markPrepared(String saleId) async {
    final success = await Provider.of<AppDataProvider>(context, listen: false)
        .markOrderPrepared(saleId);

    if (success && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Order Prepared')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<AppDataProvider>(context);
    final orders = dataProvider.pickerOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Orders'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: Colors.green[200]),
                  const SizedBox(height: 16),
                  Text('All Set! No pending orders.',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id.substring(order.id.length - 4).toUpperCase()}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status,
                                style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const Divider(height: 24),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.circle,
                                      size: 8, color: Colors.grey[400]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.productName} (${item.quantity} ${item.unitType})',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        if (item.shelfLocation != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    size: 12,
                                                    color: Colors.blue),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Location: ${item.shelfLocation}',
                                                  style: TextStyle(
                                                      color: Colors.blue[700],
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: order.isPrepared
                                ? null
                                : () => _markPrepared(order.id),
                            icon: const Icon(Icons.check),
                            label: const Text('Mark as Prepared'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
