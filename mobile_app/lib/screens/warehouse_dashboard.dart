import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/widgets/security_notice.dart';
import 'package:pos_app/screens/add_product_screen.dart';
import 'package:pos_app/screens/barcode_scanner_screen.dart';
import 'package:pos_app/services/sensory_service.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pos_app/widgets/professional_drawer.dart';
import 'package:pos_app/services/onboarding_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class WarehouseDashboard extends StatefulWidget {
  const WarehouseDashboard({super.key});

  @override
  State<WarehouseDashboard> createState() => _WarehouseDashboardState();
}

class _WarehouseDashboardState extends State<WarehouseDashboard> {
  final ScrollController _productScrollController = ScrollController();
  final GlobalKey _snapshotKey = GlobalKey();
  final GlobalKey _inventoryKey = GlobalKey();
  final GlobalKey _restockKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _productScrollController.addListener(_onProductScroll);
    _refreshProducts(); // Renamed from _refresh to be more specific
    _checkOnboarding();
  }

  void _refreshProducts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppDataProvider>(context, listen: false)
            .fetchProducts(refresh: true);
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
        title: const Text('Welcome! 📦'),
        content:
            const Text('Would you like a quick tour of your Logistics Hub?'),
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
      key: _snapshotKey,
      identify: "snapshot",
      title: "Logistics Health",
      content: "Monitor stock health and low stock criticalities at a glance.",
    ));
    targets.add(OnboardingService.createTarget(
      key: _inventoryKey,
      identify: "inventory",
      title: "Inventory Management",
      content:
          "View products, manage levels, and request restocks effortlessly.",
    ));
    targets.add(OnboardingService.createTarget(
      key: _restockKey,
      identify: "restock",
      title: "Restock Requests",
      content: "Process incoming restock orders from your sales teams.",
    ));

    OnboardingService.showTour(
      context,
      targets: targets,
      onFinish: () => Provider.of<AuthProvider>(context, listen: false)
          .completeOnboarding(),
    );
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
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<AppDataProvider>(context);
    final company = authProvider.currentCompany;
    final brandColor = company != null
        ? AppTheme.hexToColor(company.primaryColor)
        : AppTheme.primaryColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const ProfessionalDrawer(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: company?.logoUrl.isNotEmpty == true
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Hero(
                    tag: 'companyLogo',
                    child: Image.network(company!.logoUrl, fit: BoxFit.contain),
                  ),
                )
              : const Icon(Icons.inventory_2_rounded, color: Colors.blueGrey),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(company?.name ?? 'Inventory',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Colors.black87)),
              Text('LOGISTICS HUB',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: brandColor.withValues(alpha: 0.7))),
            ],
          ),
          bottom: TabBar(
            key: _restockKey,
            indicatorColor: brandColor,
            labelColor: brandColor,
            unselectedLabelColor: Colors.grey,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(
                  text: 'STOCK',
                  icon: Icon(Icons.inventory_2_rounded, size: 20)),
              Tab(
                  text: 'REQUESTS',
                  icon: Icon(Icons.notifications_active_rounded, size: 20)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.qr_code_scanner_rounded, color: brandColor),
              onPressed: () => _handleBarcodeScan(dataProvider),
            ),
            _buildNotificationBadge(dataProvider),
            IconButton(
              icon: const Icon(Icons.person_outline_rounded,
                  color: Colors.black87),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: () => dataProvider.fetchProducts(refresh: true),
              child: CustomScrollView(
                controller: _productScrollController,
                slivers: [
                  const SliverToBoxAdapter(child: SecurityNotice()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Logistics Health Snapshot
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                          key: _snapshotKey,
                          child: _buildLogisticsSnapshot(
                              dataProvider, brandColor)),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  if (dataProvider.products.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        key: _inventoryKey,
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == dataProvider.products.length) {
                              return dataProvider.hasMoreProducts
                                  ? const Center(
                                      child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: CircularProgressIndicator()))
                                  : const SizedBox(height: 100);
                            }
                            final product = dataProvider.products[index];
                            return _buildInventoryBentoCard(
                                product, brandColor);
                          },
                          childCount: dataProvider.products.length + 1,
                        ),
                      ),
                    ),
                ],
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

  Widget _buildNotificationBadge(AppDataProvider data) {
    return IconButton(
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

  Future<void> _handleBarcodeScan(AppDataProvider dataProvider) async {
    final code = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    if (code != null && mounted) {
      final product = await dataProvider.getProductByBarcode(code);
      if (!mounted) return;
      if (product != null) {
        _showEditStockDialog(context, product, dataProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Product not found'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Widget _buildLogisticsSnapshot(AppDataProvider data, Color brandColor) {
    final lowStockCount =
        data.products.where((p) => p.currentStock < 10).length;
    final pendingRequests = data.restockRequests.length;

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
          _buildSnapshotItem(
              'Health',
              lowStockCount > 0 ? 'Action Needed' : 'Healthy',
              lowStockCount > 0
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
              lowStockCount > 0 ? Colors.orange : Colors.green),
          Container(height: 40, width: 1, color: Colors.grey[100]),
          _buildSnapshotItem('Requests', '$pendingRequests',
              Icons.assignment_late_rounded, brandColor),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSnapshotItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 14)),
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryBentoCard(dynamic product, Color brandColor) {
    final isLowStock = product.currentStock < 10;
    final statusColor = isLowStock ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: brandColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16)),
                        child: Icon(_getProductIcon(product.category),
                            color: brandColor.withValues(alpha: 0.7), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: -0.5)),
                            Text('${product.category} • ${product.unitType}',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${product.currentStock}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: statusColor)),
                          IconButton(
                            icon: Icon(Icons.edit_note_rounded,
                                color: brandColor),
                            onPressed: () => _showEditStockDialog(
                                context,
                                product,
                                Provider.of<AppDataProvider>(context,
                                    listen: false)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
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

  Widget _buildRestockTab(AppDataProvider dataProvider) {
    if (dataProvider.restockRequests.isEmpty) {
      if (mounted) dataProvider.fetchRestockRequests();
      return const Center(child: Text('No pending requests'));
    }

    return ListView.builder(
      itemCount: dataProvider.restockRequests.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final req = dataProvider.restockRequests[index];
        final product = req['product'];
        final requester = req['requestedBy'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
              ]),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.priority_high_rounded, color: Colors.orange),
            ),
            title: Text(product['name'] ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Requested by: ${requester['name'] ?? 'Unknown'}'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                foregroundColor: Colors.blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => dataProvider.fulfillRestockRequest(req['_id']),
              child: const Text('Fulfill',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Update Stock: ${product.name}',
            style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New Quantity',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                final success =
                    await provider.updateProductStock(product.id, newStock);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    SensoryService.playSuccess();
                    SensoryService.successVibration();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Stock updated safely'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
