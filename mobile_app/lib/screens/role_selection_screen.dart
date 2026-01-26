import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:pos_app/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final roles = authProvider.roles;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: AppTheme.primaryColor)
                  .animate()
                  .fadeIn()
                  .scale(),
              const SizedBox(height: 32),
              Text(
                'Welcome, ${authProvider.name}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('Select your workspace',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 48),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: roles.map((role) {
                  return GestureDetector(
                    onTap: () {
                      authProvider.setCurrentRole(role);
                      Navigator.pushReplacementNamed(context, '/$role');
                    },
                    child: GlassContainer(
                        width: 150,
                        height: 150,
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_getRoleIcon(role),
                                size: 40, color: _getRoleColor(role)),
                            const SizedBox(height: 12),
                            Text(
                              role.toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getRoleColor(role)),
                            )
                          ],
                        )),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOut);
                }).toList(),
              ),
              const SizedBox(height: 48),
              TextButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text('Logout'),
              )
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'sales':
        return Icons.point_of_sale;
      case 'warehouse':
        return Icons.inventory;
      case 'picker':
        return Icons.local_shipping;
      case 'accountant':
        return Icons.account_balance;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.redAccent;
      case 'sales':
        return Colors.blue;
      case 'warehouse':
        return Colors.orange;
      case 'picker':
        return Colors.green;
      case 'accountant':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
