import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';

class SupplierMgmtScreen extends StatefulWidget {
  const SupplierMgmtScreen({super.key});

  @override
  State<SupplierMgmtScreen> createState() => _SupplierMgmtScreenState();
}

class _SupplierMgmtScreenState extends State<SupplierMgmtScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);
      provider.fetchSuppliers();
      provider.fetchPurchaseOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Supply Chain'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Suppliers'),
            Tab(text: 'Purchase Orders'),
          ]),
        ),
        body: TabBarView(
          children: [
            _buildSuppliersTab(),
            _buildPOTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliersTab() {
    final dataProvider = Provider.of<AppDataProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplierDialog(),
        child: const Icon(Icons.add),
      ),
      body: dataProvider.suppliers.isEmpty
          ? const Center(child: Text('No suppliers added'))
          : ListView.builder(
              itemCount: dataProvider.suppliers.length,
              itemBuilder: (context, index) {
                final s = dataProvider.suppliers[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.business)),
                  title: Text(s.name),
                  subtitle: Text(s.phone ?? s.email ?? 'No contact info'),
                );
              },
            ),
    );
  }

  Widget _buildPOTab() {
    final dataProvider = Provider.of<AppDataProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePODialog(),
        child: const Icon(Icons.post_add),
      ),
      body: dataProvider.purchaseOrders.isEmpty
          ? const Center(child: Text('No purchase orders'))
          : ListView.builder(
              itemCount: dataProvider.purchaseOrders.length,
              itemBuilder: (context, index) {
                final po = dataProvider.purchaseOrders[index];
                return ExpansionTile(
                  leading: _buildStatusIcon(po.status),
                  title: Text('PO for ${po.supplierName}'),
                  subtitle: Text(
                      'Status: ${po.status.toUpperCase()} • Total: \$${po.totalCost}'),
                  children: [
                    ...po.items.map((item) => ListTile(
                          title: Text(item.productName ?? 'Product'),
                          trailing: Text('Qty: ${item.quantity}'),
                        )),
                    if (po.status == 'ordered')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () =>
                              dataProvider.updatePOStatus(po.id, 'received'),
                          child: const Text('Mark as Received & Update Stock'),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'received':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'ordered':
        icon = Icons.local_shipping;
        color = Colors.orange;
        break;
      default:
        icon = Icons.timer;
        color = Colors.grey;
    }
    return Icon(icon, color: color);
  }

  void _showAddSupplierDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final success =
                    await Provider.of<AppDataProvider>(context, listen: false)
                        .createSupplier({
                  'name': nameController.text,
                  'phone': phoneController.text,
                });
                if (success && context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCreatePODialog() {
    // Simplified for now: just creates a dummy PO for testing the flow
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PO Creation Wizard coming soon!')));
  }
}
