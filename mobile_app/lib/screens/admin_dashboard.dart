import 'package:flutter/material.dart';
import 'package:pos_app/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/widgets/professional_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: authProvider.currentCompany?.logoUrl.isNotEmpty == true
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(authProvider.currentCompany!.logoUrl),
              )
            : null,
        title: Text(authProvider.currentCompany?.name ?? 'Admin Console',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Consumer<AppDataProvider>(
            builder: (context, data, _) => IconButton(
              icon: Badge(
                label: data.unreadNotifications > 0
                    ? Text('${data.unreadNotifications}')
                    : null,
                isLabelVisible: data.unreadNotifications > 0,
                child: const Icon(Icons.notifications_outlined,
                    color: Colors.black87),
              ),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          )
        ],
      ),
      drawer: const ProfessionalDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F4F8), Color(0xFFE1E8ED)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Actions',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        title: 'Manage Users',
                        subtitle: 'Roles, Access',
                        icon: Icons.people_alt_rounded,
                        color: Colors.blueAccent,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/users'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        title: 'System Health',
                        subtitle: 'All Systems Go',
                        icon: Icons.monitor_heart,
                        color: Colors.green,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Department Views',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 16),
                _buildDepartmentTile(context, 'Sales Department',
                    Icons.point_of_sale, Colors.indigo, '/sales'),
                const SizedBox(height: 12),
                _buildDepartmentTile(context, 'Warehouse / Inventory',
                    Icons.inventory_2, Colors.orange, '/warehouse'),
                const SizedBox(height: 12),
                _buildDepartmentTile(context, 'Finance / Accounting',
                    Icons.pie_chart, Colors.purple, '/accountant'),
                const SizedBox(height: 24),
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Admin Notice')
                      ]),
                      const SizedBox(height: 12),
                      Text(
                          'You have full access to all modules. Use the "User Management" tool to add new employees or reset passwords.',
                          style:
                              TextStyle(color: Colors.grey[700], height: 1.5)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ).animate().scale(curve: Curves.easeOut),
    );
  }

  Widget _buildDepartmentTile(BuildContext context, String title, IconData icon,
      Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
