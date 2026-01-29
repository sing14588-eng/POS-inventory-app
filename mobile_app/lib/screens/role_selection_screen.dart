import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;

  void _handleRoleSelect(AuthProvider authProvider, String role) async {
    setState(() => _isLoading = true);

    final success = await authProvider.switchRole(role);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      String route = '/';
      switch (role) {
        case 'super_admin':
          route = '/super-admin';
          break;
        case 'shop_admin':
          route = '/shop-admin';
          break;
        case 'branch_manager':
          route = '/shop-admin';
          break;
        case 'sales':
          route = '/sales';
          break;
        case 'picker':
          route = '/picker';
          break;
        case 'warehouse':
          route = '/warehouse';
          break;
        case 'accountant':
          route = '/accountant';
          break;
      }
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to switch workspace. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... same build logic ...
    final authProvider = Provider.of<AuthProvider>(context);
    final roles = authProvider.roles;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Your Role'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome Back! 👋',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You have multiple roles assigned.\nPlease select the workspace you want to enter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView.separated(
                      itemCount: roles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final role = roles[index];
                        return _buildRoleCard(context, role, authProvider);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRoleCard(
      BuildContext context, String role, AuthProvider authProvider) {
    IconData icon;
    Color color;

    switch (role) {
      case 'sales':
        icon = Icons.point_of_sale;
        color = Colors.blue;
        break;
      case 'branch_manager':
        icon = Icons.store;
        color = Colors.purple;
        break;
      case 'warehouse':
        icon = Icons.inventory;
        color = Colors.brown;
        break;
      case 'picker':
        icon = Icons.shopping_bag;
        color = Colors.orange;
        break;
      case 'accountant':
        icon = Icons.account_balance;
        color = Colors.teal;
        break;
      case 'shop_admin':
        icon = Icons.admin_panel_settings;
        color = Colors.indigo;
        break;
      case 'super_admin':
        icon = Icons.verified_user;
        color = Colors.red;
        break;
      default:
        icon = Icons.badge;
        color = Colors.grey;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _handleRoleSelect(authProvider, role),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.toUpperCase().replaceAll('_', ' '),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Access ${role.replaceAll('_', ' ')} workspace',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
