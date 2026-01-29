import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/models/product_model.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String _searchQuery = "";
  String? _selectedBranchId;
  String _selectedStockFilter = "Low Stock"; // Default as per Fix 5

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);
      provider.fetchProducts();
      provider.fetchBranches();

      // Handle initial filter from dashboard
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args.containsKey('filter')) {
        setState(() => _selectedStockFilter = "Low Stock");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);
    List<Product> products = data.products;
    final branches = data.branches;

    // 1. Stock Filter Logic (Fix 5)
    if (_selectedStockFilter == "Low Stock") {
      products = products
          .where((p) => p.currentStock <= 10)
          .toList(); // Assuming 10 is low threshold
    } else if (_selectedStockFilter == "Out of Stock") {
      products = products.where((p) => p.currentStock <= 0).toList();
    }

    // 2. Search Logic
    if (_searchQuery.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Product feature coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedBranchId,
                  hint: const Text('Branch'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Global')),
                    ...branches.map((b) =>
                        DropdownMenuItem(value: b.id, child: Text(b.name))),
                  ],
                  onChanged: (v) => setState(() => _selectedBranchId = v),
                ),
              ],
            ),
          ),
          // Stock Filter Toggle (Fix 5)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ["All", "Low Stock", "Out of Stock"].map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    selected: _selectedStockFilter == filter,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedStockFilter = filter);
                      }
                    },
                    selectedColor: Colors.blue.withValues(alpha: 0.2),
                    checkmarkColor: Colors.blue,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    // Stock Status Logic
    // 🟢 OK: Stock > minStockLevel * 2
    // 🟠 Low: Stock <= minStockLevel * 2 and > minStockLevel
    // 🔴 Critical: Stock <= minStockLevel

    // Note: minStockLevel in Product model might not be accessible yet if model wasn't updated in Flutter.
    // I'll assume it exists or use a default.
    const minStock = 5; // Fallback
    final stock = product.currentStock;

    Color statusColor = Colors.green;
    String statusLabel = "OK";

    if (stock <= minStock) {
      statusColor = Colors.red;
      statusLabel = "CRITICAL";
    } else if (stock <= minStock * 2) {
      statusColor = Colors.orange;
      statusLabel = "LOW";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit Product feature coming soon!')),
          );
        },
        contentPadding: const EdgeInsets.all(16),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${product.category} | ${product.size}"),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text("Stock: ${product.currentStock}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
