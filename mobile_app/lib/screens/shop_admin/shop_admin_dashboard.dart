import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';

class ShopAdminDashboard extends StatefulWidget {
  const ShopAdminDashboard({super.key});

  @override
  State<ShopAdminDashboard> createState() => _ShopAdminDashboardState();
}

class _ShopAdminDashboardState extends State<ShopAdminDashboard> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<AppDataProvider>(context, listen: false);
    await provider.fetchShopAdminDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final data = Provider.of<AppDataProvider>(context);
    final stats = data.shopAdminStats;
    final company = auth.currentCompany;
    final currency = company?.currencySymbol ?? '\$';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildWelcomeHeader(auth),
            const SizedBox(height: 24),
            _buildStatCard(
              title: "Today's Sales",
              value: "$currency${stats?['todaySales'] ?? 0}",
              icon: Icons.today_rounded,
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/reports',
                  arguments: {'tab': 0}),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: "This Month's Sales",
              value: "$currency${stats?['monthSales'] ?? 0}",
              icon: Icons.calendar_month_rounded,
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/reports',
                  arguments: {'tab': 1}),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: "Low Stock Alerts",
              value: "${stats?['lowStockCount'] ?? 0}",
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              showBadge: (stats?['lowStockCount'] ?? 0) > 0,
              onTap: () => Navigator.pushNamed(context, '/shop-admin/products',
                  arguments: {'filter': 'low_stock'}),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: "Active Branches",
              value: "${stats?['activeBranches'] ?? 0}",
              icon: Icons.storefront_rounded,
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/shop-admin/branches'),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Top Selling Product Today',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 16),
                          Text("${stats?['topProduct'] ?? 'None'}",
                              style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 24),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'))),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text('View Business Insights'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hello,", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        Text(auth.name?.split(' ')[0] ?? 'Admin',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool showBadge = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (showBadge)
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final role = Provider.of<AuthProvider>(context, listen: false).role;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_rounded, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text('SHOP ADMIN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildDrawerItem(
              context, 'Dashboard', Icons.dashboard_rounded, '/shop-admin'),
          if (role != 'branch_manager')
            _buildDrawerItem(context, 'Branches', Icons.store_rounded,
                '/shop-admin/branches'),
          _buildDrawerItem(context, 'Products', Icons.inventory_2_rounded,
              '/shop-admin/products'),
          _buildDrawerItem(
              context, 'Staff', Icons.people_rounded, '/shop-admin/staff'),
          _buildDrawerItem(
              context, 'Reports', Icons.bar_chart_rounded, '/reports'),
          _buildDrawerItem(context, 'Settings', Icons.settings_rounded,
              '/shop-admin/settings'),
          const Divider(),
          if (Provider.of<AuthProvider>(context).roles.length > 1)
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded, color: Colors.blue),
              title: const Text('Switch Workspace',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/role-selection'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
