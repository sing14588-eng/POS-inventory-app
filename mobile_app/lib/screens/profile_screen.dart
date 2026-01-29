import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/widgets/glass_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
              backgroundImage: auth.currentCompany?.logoUrl.isNotEmpty == true
                  ? NetworkImage(auth.currentCompany!.logoUrl)
                  : null,
              child: auth.currentCompany?.logoUrl.isNotEmpty == true
                  ? null
                  : const Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 24),
            Text(user?.name ?? 'Guest',
                style: Theme.of(context).textTheme.headlineMedium),
            Text(user?.email ?? '', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            _buildInfoCard(context, 'Primary Role',
                (user?.role ?? 'N/A').toUpperCase(), Icons.badge),
            const SizedBox(height: 16),
            _buildInfoCard(context, 'Business / Shop',
                user?.companyName ?? 'Platform Management', Icons.business),
            const SizedBox(height: 16),
            _buildInfoCard(
                context,
                'Assigned Roles',
                (user?.roles.join(', ') ?? 'N/A').toUpperCase(),
                Icons.security),
            const SizedBox(height: 32),
            if (user?.role == 'admin') ...[
              const Divider(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showShopSettingsDialog(context),
                  icon: const Icon(Icons.settings_suggest),
                  label: const Text('Receipt & Shop Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock_reset),
                label: const Text('Change Password'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final auth =
                      Provider.of<AuthProvider>(context, listen: false);
                  await auth.resetOnboardingLocal();
                  if (context.mounted) {
                    final route = auth.getDashboardRoute();
                    Navigator.pushNamedAndRemoveUntil(
                        context, route, (route) => false);
                  }
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Retake App Tour'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  auth.logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.length < 6) return;
              final success =
                  await Provider.of<AuthProvider>(context, listen: false)
                      .changePassword(controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(success ? 'Password Updated' : 'Update Failed'),
                      backgroundColor: success ? Colors.green : Colors.red),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showShopSettingsDialog(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final company = auth.currentCompany;
    if (company == null) return;

    final headerController = TextEditingController(text: company.receiptHeader);
    final footerController = TextEditingController(text: company.receiptFooter);
    final phoneController = TextEditingController(text: company.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt Customization'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: headerController,
                decoration: const InputDecoration(
                    labelText: 'Receipt Header',
                    hintText: 'e.g. "Welcome to our shop!"'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: footerController,
                decoration: const InputDecoration(
                    labelText: 'Receipt Footer',
                    hintText: 'e.g. "No refunds after 7 days"'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Store Phone'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success =
                  await Provider.of<AppDataProvider>(context, listen: false)
                      .updateCompany(company.id, {
                'receiptHeader': headerController.text,
                'receiptFooter': footerController.text,
                'phone': phoneController.text,
              });
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Shop Settings Updated'),
                        backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String label, String value, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
