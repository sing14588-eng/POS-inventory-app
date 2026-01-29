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
import 'package:pos_app/services/receipt_service.dart';
import 'package:pos_app/services/sensory_service.dart';
import 'package:pos_app/services/onboarding_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:pos_app/widgets/security_notice.dart';
import 'package:pos_app/widgets/professional_drawer.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  final Map<String, int> _cart = {}; // productId -> quantity
  bool _isCredit = false;
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _scanKey = GlobalKey();
  final GlobalKey _notificationsKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();
  final GlobalKey _cartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final dataProvider =
            Provider.of<AppDataProvider>(context, listen: false);
        dataProvider.fetchProducts(refresh: true);

        _checkOnboarding();
      }
    });
  }

  void _checkOnboarding() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.onboardingCompleted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _showOnboardingWelcome();
      });
    }
  }

  void _showOnboardingWelcome() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome! 🚀'),
        content: const Text(
            'Would you like a quick 1-minute tour of your Sales Dashboard?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false)
                  .completeOnboarding();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startTour();
            },
            child: const Text('Start Tour'),
          ),
        ],
      ),
    );
  }

  void _startTour() {
    List<TargetFocus> targets = [];

    targets.add(OnboardingService.createTarget(
      key: _searchKey,
      identify: "search",
      title: "Product Search",
      content: "Quickly find products by name or category here.",
    ));

    targets.add(OnboardingService.createTarget(
      key: _scanKey,
      identify: "scan",
      title: "Barcode Scanner",
      content: "Tap here to scan product barcodes and add them to your cart.",
    ));

    targets.add(OnboardingService.createTarget(
      key: _cartKey,
      identify: "cart",
      title: "Shopping Cart",
      content: "Review selected items, set credit status, and checkout here.",
    ));

    targets.add(OnboardingService.createTarget(
      key: _historyKey,
      identify: "history",
      title: "Sales History",
      content: "View your past sales and print receipts from here.",
      align: ContentAlign.top,
    ));

    targets.add(OnboardingService.createTarget(
      key: _notificationsKey,
      identify: "notifications",
      title: "Notifications",
      content: "Stay updated on low stock alerts and restock requests.",
    ));

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.blueGrey[900]!,
      textSkip: "SKIP",
      onFinish: () => Provider.of<AuthProvider>(context, listen: false)
          .completeOnboarding(),
      onSkip: () {
        Provider.of<AuthProvider>(context, listen: false).completeOnboarding();
        return true;
      },
    ).show(context: context);
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
      SensoryService.successVibration();
      // Minimal feedback as we have a reactive cart summary
    } else {
      SensoryService.playError();
      SensoryService.errorVibration();
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
                              activeTrackColor: AppTheme.primaryColor,
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

    final createdSale = await dataProvider.createSale(saleItems, _isCredit);

    if (mounted) {
      if (createdSale != null) {
        setState(() {
          _cart.clear();
          _isCredit = false;
        });
        SensoryService.playSuccess();
        SensoryService.successVibration();
        _showSuccessDialog(createdSale);
      } else {
        SensoryService.playError();
        SensoryService.errorVibration();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sale Failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog(Sale sale) {
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
              const SizedBox(height: 16),
              Text('Order Total: \$${sale.totalAmount}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final auth =
                            Provider.of<AuthProvider>(context, listen: false);
                        if (auth.currentCompany != null) {
                          ReceiptService.generateAndPrintReceipt(
                              sale, auth.currentCompany!);
                        }
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Print Receipt'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
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
    final authProvider = Provider.of<AuthProvider>(context);
    final products = dataProvider.products;
    final company = authProvider.currentCompany;
    final brandColor = company != null
        ? AppTheme.hexToColor(company.primaryColor)
        : AppTheme.primaryColor;

    return Scaffold(
      drawer: const ProfessionalDrawer(),
      body: Stack(
        children: [
          // Dynamic Branded Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  brandColor.withValues(alpha: 0.08),
                  const Color(0xFFF8FAFC),
                  const Color(0xFFF1F5F9),
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
                  expandedHeight: 140,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: company?.logoUrl.isNotEmpty == true
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Hero(
                            tag: 'companyLogo',
                            child: Image.network(company!.logoUrl,
                                fit: BoxFit.contain),
                          ),
                        )
                      : const Icon(Icons.bolt_rounded, color: Colors.amber),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company?.name ?? 'Sales Point',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black87)),
                      Text('FRONTLINE CONSOLE',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: brandColor.withValues(alpha: 0.7))),
                    ],
                  ),
                  centerTitle: false,
                  actions: [
                    _buildOfflineIndicator(),
                    IconButton(
                      key: _historyKey,
                      icon: Icon(Icons.receipt_long_rounded, color: brandColor),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/sales/history'),
                    ),
                    _buildNotificationBadge(dataProvider),
                    IconButton(
                      key: _profileKey,
                      icon: const Icon(Icons.person_outline_rounded,
                          color: Colors.black87),
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                      alignment: Alignment.bottomCenter,
                      child: _buildSearchBar(dataProvider, brandColor),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SecurityNotice()),

                // Personal Performance Snapshot (Modern Bento Tool)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child:
                        _buildPersonalImpactSnapshot(dataProvider, brandColor),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text('Available Inventory',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey,
                            letterSpacing: 1)),
                  ),
                ),
                const SliverToBoxAdapter(child: SecurityNotice()),

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
              key: _cartKey,
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

  Widget _buildOfflineIndicator() {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline = snapshot.data != null &&
            snapshot.data!.contains(ConnectivityResult.none);
        if (!isOffline) return const SizedBox.shrink();
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(Icons.wifi_off_rounded, color: Colors.redAccent),
        );
      },
    );
  }

  Widget _buildNotificationBadge(AppDataProvider data) {
    return IconButton(
      key: _notificationsKey,
      icon: Badge(
        label: data.unreadNotifications > 0
            ? Text('${data.unreadNotifications}')
            : null,
        isLabelVisible: data.unreadNotifications > 0,
        backgroundColor: Colors.redAccent,
        child:
            const Icon(Icons.notifications_none_rounded, color: Colors.black87),
      ),
      onPressed: () => Navigator.pushNamed(context, '/notifications'),
    );
  }

  Widget _buildSearchBar(AppDataProvider dataProvider, Color brandColor) {
    return GlassContainer(
      blur: 10,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(20),
      child: TextField(
        key: _searchKey,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: brandColor),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: IconButton(
            key: _scanKey,
            icon: Icon(Icons.qr_code_scanner_rounded, color: brandColor),
            onPressed: () => _handleBarcodeScan(dataProvider),
          ),
        ),
        onChanged: (value) => dataProvider.searchProducts(value),
      ),
    );
  }

  Future<void> _handleBarcodeScan(AppDataProvider dataProvider) async {
    final code = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    if (code != null && mounted) {
      final product = await dataProvider.getProductByBarcode(code);
      if (!mounted) return;
      if (product != null) {
        _addToCart(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${product.name} to cart'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product not found'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildPersonalImpactSnapshot(AppDataProvider data, Color brandColor) {
    // Note: In a real app, this would be filtered for the CURRENT user
    final report = data.dailyReport;
    final totalSales = report?['totalSales'] ?? 0.0;
    final txCount = report?['transactionCount'] ?? 0;
    final currency = Provider.of<AuthProvider>(context, listen: false)
            .currentCompany
            ?.currencySymbol ??
        '\$';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: brandColor.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Row(
        children: [
          _buildImpactItem('Daily Sales', '$currency$totalSales',
              Icons.auto_graph_rounded, brandColor),
          Container(height: 40, width: 1, color: Colors.grey[100]),
          _buildImpactItem('Transactions', '$txCount',
              Icons.shopping_bag_outlined, Colors.blueGrey),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildImpactItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5)),
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, int qty) {
    final isOutOfStock = product.currentStock <= 0;
    final company =
        Provider.of<AuthProvider>(context, listen: false).currentCompany;
    final brandColor = company != null
        ? AppTheme.hexToColor(company.primaryColor)
        : AppTheme.primaryColor;

    return GestureDetector(
      onTap: isOutOfStock ? null : () => _addToCart(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? Colors.grey[50]
                          : brandColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: Icon(
                        _getProductIcon(product.category),
                        size: 40,
                        color: isOutOfStock
                            ? Colors.grey[300]
                            : brandColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  if (qty > 0)
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: brandColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$qty',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ).animate().scale(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${company?.currencySymbol ?? '\$'}${product.price}',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: brandColor,
                              fontSize: 16)),
                      Text('${product.currentStock} left',
                          style: TextStyle(
                              color:
                                  isOutOfStock ? Colors.red : Colors.grey[400],
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon(String? category) {
    category = category?.toLowerCase();
    if (category == null) {
      return Icons.inventory_2_rounded;
    }
    if (category.contains('drink') || category.contains('beverage')) {
      return Icons.local_cafe_rounded;
    }
    if (category.contains('food') || category.contains('snack')) {
      return Icons.fastfood_rounded;
    }
    if (category.contains('electronic')) {
      return Icons.devices_rounded;
    }
    if (category.contains('cloth')) {
      return Icons.checkroom_rounded;
    }
    return Icons.inventory_2_rounded;
  }
}
