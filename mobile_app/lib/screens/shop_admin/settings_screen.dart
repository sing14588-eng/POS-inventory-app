import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';

class ShopAdminSettingsScreen extends StatelessWidget {
  const ShopAdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final company = auth.currentCompany;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader('Shop Profile'),
          ListTile(
            leading: const Icon(Icons.business_rounded),
            title: const Text('Shop Name'),
            subtitle: Text(company?.name ?? 'Not set'),
            trailing: const Icon(Icons.edit_outlined),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Contact Email'),
            subtitle: Text(company?.email ?? 'Not set'),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange_rounded),
            title: const Text('Currency & Tax'),
            subtitle: Text('Symbol: ${company?.currencySymbol ?? '\$'}'),
          ),
          _buildSectionHeader('Security'),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Change Password'),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.phonelink_erase_rounded),
            title: const Text('Logout All Devices'),
            onTap: () {},
          ),
          _buildSectionHeader('Preferences'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (v) {},
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50], foregroundColor: Colors.red),
              onPressed: () => auth.logout(),
              child: const Text('LOGOUT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }
}
