import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/widgets/security_notice.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pos_app/widgets/professional_drawer.dart';
import 'package:pos_app/services/onboarding_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class PickerDashboard extends StatefulWidget {
  const PickerDashboard({super.key});

  @override
  State<PickerDashboard> createState() => _PickerDashboardState();
}

class _PickerDashboardState extends State<PickerDashboard> {
  final GlobalKey _efficiencyKey = GlobalKey();
  final GlobalKey _ticketKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _refresh();
    _checkOnboarding();
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
        title: const Text('Welcome! 🛒'),
        content:
            const Text('Would you like a quick tour of your Picking Console?'),
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
      key: _efficiencyKey,
      identify: "efficiency",
      title: "Picking Efficiency",
      content: "Track your active picking queue and today's fulfillment rate.",
    ));
    targets.add(OnboardingService.createTarget(
      key: _ticketKey,
      identify: "ticket",
      title: "Precision Picking",
      content: "View itemized lists with shelf locations for maximum speed.",
    ));

    OnboardingService.showTour(
      context,
      targets: targets,
      onFinish: () => Provider.of<AuthProvider>(context, listen: false)
          .completeOnboarding(),
    );
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
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<AppDataProvider>(context);
    final company = authProvider.currentCompany;
    final brandColor = company != null
        ? AppTheme.hexToColor(company.primaryColor)
        : AppTheme.primaryColor;
    final orders = dataProvider.pickerOrders;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
            : const Icon(Icons.shopping_basket_rounded, color: Colors.blueGrey),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(company?.name ?? 'Orders',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: Colors.black87)),
            Text('PICKING CONSOLE',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: brandColor.withValues(alpha: 0.7))),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh_rounded, color: brandColor),
              onPressed: _refresh),
          _buildNotificationBadge(dataProvider),
          IconButton(
            icon:
                const Icon(Icons.person_outline_rounded, color: Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SecurityNotice(),
                  const SizedBox(height: 20),
                  Container(
                      key: _efficiencyKey,
                      child: _buildEfficiencySnapshot(orders, brandColor)),
                  const SizedBox(height: 24),
                  Text('Active Pick-Lists',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.blueGrey[900])),
                ],
              ),
            ),
          ),
          orders.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 80,
                            color: Colors.green.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text('ALL DONE!',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2)),
                        Text('No pending orders to pick.',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                          key: index == 0 ? _ticketKey : null,
                          child: _buildPickTicket(orders[index], brandColor)),
                      childCount: orders.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildPickTicket(dynamic order, Color brandColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: brandColor.withValues(alpha: 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'ORDER #${order.id.substring(order.id.length - 4).toUpperCase()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: -0.5)),
                      Text('${order.items.length} items to pick',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('PENDING',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ...order.items
                      .map((item) => _buildPickItem(item, brandColor)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _markPrepared(order.id),
                      icon: const Icon(Icons.verified_rounded),
                      label: const Text('READY FOR COLLECTION',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildPickItem(dynamic item, Color brandColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12)),
            child: Icon(_getProductIcon(item.productName),
                color: Colors.blueGrey[400], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Qty: ${item.quantity} ${item.unitType}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),
          if (item.shelfLocation != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.blue, size: 12),
                  const SizedBox(width: 4),
                  Text(item.shelfLocation,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w900,
                          fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEfficiencySnapshot(List orders, Color brandColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: brandColor.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 15))
        ],
      ),
      child: Row(
        children: [
          _buildSnapshotItem('Active Orders', '${orders.length}',
              Icons.pending_actions_rounded, Colors.orange),
          Container(height: 40, width: 1, color: Colors.grey[100]),
          _buildSnapshotItem(
              'Pick Rate', '94%', Icons.speed_rounded, Colors.green),
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

  IconData _getProductIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('drink') ||
        name.contains('juice') ||
        name.contains('coke')) {
      return Icons.local_cafe_rounded;
    }
    if (name.contains('burger') ||
        name.contains('food') ||
        name.contains('snack')) {
      return Icons.fastfood_rounded;
    }
    if (name.contains('cable') ||
        name.contains('phone') ||
        name.contains('apple')) {
      return Icons.devices_rounded;
    }
    return Icons.inventory_2_rounded;
  }
}
