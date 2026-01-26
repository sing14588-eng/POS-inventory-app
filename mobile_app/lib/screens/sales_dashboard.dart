import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/models/product_model.dart';
import 'package:pos_app/models/sale_model.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:pos_app/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pos_app/screens/barcode_scanner_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  final Map<String, int> _cart = {}; // productId -> quantity
  bool _isCredit = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppDataProvider>(context, listen: false)
            .fetchProducts(refresh: true);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);
      if (provider.hasMoreProducts) {
        provider.fetchProducts(refresh: false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    if (product.currentStock > (_cart[product.id] ?? 0)) {
      setState(() {
        _cart[product.id] = (_cart[product.id] ?? 0) + 1;
      });
      // Minimal feedback as we have a reactive cart summary
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Out of Stock'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeFromCart(String productId) {
    if ((_cart[productId] ?? 0) > 0) {
      setState(() {
        _cart[productId] = _cart[productId]! - 1;
        if (_cart[productId] == 0) _cart.remove(productId);
      });
    }
  }

  int get _cartTotalItems => _cart.values.fold(0, (sum, qty) => sum + qty);
  double get _cartTotalPrice {
    final products =
        Provider.of<AppDataProvider>(context, listen: false).products;
    double total = 0;
    _cart.forEach((pid, qty) {
      final p =
          products.firstWhere((p) => p.id == pid, orElse: () => products[0]);
      total += p.price * qty;
    });
    return total;
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final dataProvider =
              Provider.of<AppDataProvider>(context, listen: false);
          final products = dataProvider.products;

          return GlassContainer(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            color: Theme.of(context)
                .scaffoldBackgroundColor
                .withValues(alpha: 0.95),
            blur: 20,
            padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Order',
                          style: Theme.of(context).textTheme.headlineSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_cartTotalItems Items',
                          style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _cart.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_cart_outlined,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text('Your cart is empty',
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _cart.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final pid = _cart.keys.elementAt(index);
                              final qty = _cart[pid]!;
                              final product =
                                  products.firstWhere((p) => p.id == pid);

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.inventory_2_outlined,
                                          color: AppTheme.primaryColor),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text('\$${product.price}',
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _buildQtyBtn(Icons.remove, () {
                                          _removeFromCart(pid);
                                          setSheetState(() {});
                                          setState(() {});
                                        }),
                                        SizedBox(
                                          width: 32,
                                          child: Text('$qty',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        _buildQtyBtn(Icons.add, () {
                                          if (product.currentStock > qty) {
                                            setState(() {
                                              _cart[pid] = qty + 1;
                                            });
                                            setSheetState(() {});
                                          }
                                        }),
                                      ],
                                    )
                                  ],
                                ),
                              ).animate().fadeIn().slideX();
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                  GlassContainer(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            Text('\$$_cartTotalPrice',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text('Credit Sale?',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const Spacer(),
                            Switch(
                              value: _isCredit,
                              activeThumbColor: AppTheme.primaryColor,
                              onChanged: (v) {
                                setState(() => _isCredit = v);
                                setSheetState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cart.isEmpty
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    _checkout();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // High contrast
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            child: const Text('Checkout',
                                style: TextStyle(fontSize: 18)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  void _checkout() async {
    final dataProvider = Provider.of<AppDataProvider>(context, listen: false);
    final products = dataProvider.products;

    final saleItems = _cart.entries.map((entry) {
      final product = products.firstWhere((p) => p.id == entry.key);
      return SaleItem(
        productId: product.id,
        productName: product.name,
        quantity: entry.value,
        unitType: product.unitType,
        pricePerUnit: product.price,
        total: product.price * entry.value,
      );
    }).toList();

    final success = await dataProvider.createSale(saleItems, _isCredit);

    if (mounted) {
      if (success) {
        setState(() {
          _cart.clear();
          _isCredit = false;
        });
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sale Failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          color: Colors.white,
          opacity: 0.9,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
              const SizedBox(height: 24),
              Text('Success!',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Transaction completed successfully.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<AppDataProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final products = dataProvider.products;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),

          RefreshIndicator(
            onRefresh: () => dataProvider.fetchProducts(refresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: true,
                  pinned: true,
                  backgroundColor:
                      Colors.transparent, // Let body logic handle bg
                  title: Text('POS Terminal',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  centerTitle: false,
                  actions: [
                    StreamBuilder<List<ConnectivityResult>>(
                      stream: Connectivity().onConnectivityChanged,
                      builder: (context, snapshot) {
                        final isOffline = snapshot.data != null &&
                            snapshot.data!.contains(ConnectivityResult.none);
                        if (!isOffline) return const SizedBox.shrink();
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.wifi_off, color: Colors.red),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.history,
                          color: AppTheme.primaryColor),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/sales/history'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      onPressed: () {
                        authProvider.logout();
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.8),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.qr_code_scanner),
                              onPressed: () async {
                                final code = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BarcodeScannerScreen(),
                                  ),
                                );
                                if (code != null && context.mounted) {
                                  final product = await dataProvider
                                      .getProductByBarcode(code);
                                  if (!context.mounted) return;
                                  if (product != null) {
                                    _addToCart(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Added ${product.name} to cart'),
                                          backgroundColor: Colors.green),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Product not found'),
                                          backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          onChanged: (value) {
                            dataProvider.searchProducts(value);
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                if (products.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == products.length) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final product = products[index];
                          final qtyInCart = _cart[product.id] ?? 0;
                          return _buildProductCard(product, qtyInCart);
                        },
                        childCount: products.length +
                            (dataProvider.hasMoreProducts ? 1 : 0),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                    child: SizedBox(height: 100)), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _cartTotalItems > 0
          ? FloatingActionButton.extended(
              onPressed: _showCartSheet,
              label: Row(
                children: [
                  Text('$_cartTotalItems Items'),
                  const SizedBox(width: 8),
                  Container(height: 20, width: 1, color: Colors.white24),
                  const SizedBox(width: 8),
                  Text('\$$_cartTotalPrice'),
                ],
              ),
              icon: const Icon(Icons.shopping_cart),
            ).animate().scale(curve: Curves.elasticOut)
          : null,
    );
  }

  Widget _buildProductCard(Product product, int qty) {
    final isOutOfStock = product.currentStock <= 0;

    return GestureDetector(
      onTap: isOutOfStock ? null : () => _addToCart(product),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? Colors.grey[100]
                          : AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Center(
                      child: Icon(
                        isOutOfStock
                            ? Icons.production_quantity_limits
                            : Icons.inventory_2,
                        size: 48,
                        color:
                            isOutOfStock ? Colors.grey : AppTheme.primaryColor,
                      )
                          .animate(target: isOutOfStock ? 0 : 1)
                          .scale(duration: 300.ms),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(product.category,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$${product.price}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 18)),
                            if (isOutOfStock)
                              InkWell(
                                onTap: () async {
                                  // Request restock
                                  final success =
                                      await Provider.of<AppDataProvider>(
                                              context,
                                              listen: false)
                                          .createRestockRequest(product.id);

                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Restock requested!'),
                                          backgroundColor: Colors.blue),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Notify Warehouse',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          if (qty > 0)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]),
                child: Text('$qty',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ).animate().scale(curve: Curves.elasticOut),
            )
        ],
      )
          .animate()
          .fadeIn()
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
    );
  }
}
