import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/screens/add_product_screen.dart';
import 'package:pos_app/screens/barcode_scanner_screen.dart';

class WarehouseDashboard extends StatefulWidget {
  const WarehouseDashboard({super.key});

  @override
  State<WarehouseDashboard> createState() => _WarehouseDashboardState();
}

class _WarehouseDashboardState extends State<WarehouseDashboard> {
  final ScrollController _productScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _productScrollController.addListener(_onProductScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppDataProvider>(context, listen: false)
            .fetchProducts(refresh: true);
      }
    });
  }

  void _onProductScroll() {
    if (_productScrollController.position.pixels >=
        _productScrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);
      if (provider.hasMoreProducts) {
        provider.fetchProducts(refresh: false);
      }
    }
  }

  @override
  void dispose() {
    _productScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<AppDataProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stock', icon: Icon(Icons.inventory)),
              Tab(
                  text: 'Restock Requests',
                  icon: Icon(Icons.notifications_active)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () async {
                final code = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerScreen(),
                  ),
                );
                if (code != null && context.mounted) {
                  final product = await dataProvider.getProductByBarcode(code);
                  if (product != null && context.mounted) {
                    _showEditStockDialog(context, product, dataProvider);
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Product not found'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Inventory List
            // Tab 1: Inventory List
            RefreshIndicator(
              onRefresh: () => dataProvider.fetchProducts(refresh: true),
              child: dataProvider.products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No products found',
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _productScrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: dataProvider.products.length +
                          (dataProvider.hasMoreProducts ? 1 : 0) +
                          1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Low Stock Alert Header
                          if (dataProvider.products
                              .any((p) => p.currentStock < 10)) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            Colors.red.withValues(alpha: 0.3))),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning,
                                        color: Colors.red),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(
                                            'Alert: ${dataProvider.products.where((p) => p.currentStock < 10).length} items are low on stock!',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        final listIndex = index - 1;
                        if (listIndex == dataProvider.products.length) {
                          return const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator()));
                        }

                        final product = dataProvider.products[listIndex];
                        final isLowStock = product.currentStock < 10;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: isLowStock
                                  ? Colors.red[100]
                                  : Colors.green[100],
                              child: Icon(
                                isLowStock
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline,
                                color: isLowStock ? Colors.red : Colors.green,
                              ),
                            ),
                            title: Text(product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${product.category} • ${product.currentStock} ${product.unitType}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${product.currentStock}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _showEditStockDialog(
                                      context, product, dataProvider),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Tab 2: Restock Requests
            _buildRestockTab(dataProvider),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
        ),
      ),
    );
  }

  Widget _buildRestockTab(AppDataProvider dataProvider) {
    if (dataProvider.restockRequests.isEmpty) {
      if (mounted) dataProvider.fetchRestockRequests(); // Fetch if empty
      return const Center(child: Text('No pending requests'));
    }

    return ListView.builder(
      itemCount: dataProvider.restockRequests.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final req = dataProvider.restockRequests[index];
        final product = req['product'];
        final requester = req['requestedBy'];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.priority_high, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'] ?? 'Unknown',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Stock: ${product['currentStock']}',
                          style: TextStyle(color: Colors.grey[600])),
                      Text('Requested by: ${requester['name'] ?? 'Unknown'}',
                          style: const TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    dataProvider.fulfillRestockRequest(req['_id']);
                  },
                  child: const Text('Mark Done'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditStockDialog(
      BuildContext context, dynamic product, AppDataProvider provider) {
    final controller =
        TextEditingController(text: product.currentStock.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Stock: ${product.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'New Stock Quantity', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                final success =
                    await provider.updateProductStock(product.id, newStock);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Stock updated successfully'),
                        backgroundColor: Colors.green));
                  }
                }
              }
            },
            child: const Text('Update'),
          )
        ],
      ),
    );
  }
}
