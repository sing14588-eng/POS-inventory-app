import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';

class SuperAdminSettingsScreen extends StatelessWidget {
  const SuperAdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('SYSTEM PREFERENCES',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 16),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.grey[100],
            leading: const Icon(Icons.security_rounded, color: Colors.blue),
            title: const Text('Security Audit'),
            subtitle: const Text('All actions are being logged'),
            trailing:
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.grey[100],
            leading:
                const Icon(Icons.info_outline_rounded, color: Colors.orange),
            title: const Text('Version'),
            subtitle: const Text('FlowPOS v1.0.0 (MVP)'),
          ),
          const Divider(height: 48),
          const Text('ACCOUNT',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 16),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.red.withValues(alpha: 0.05),
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout Session',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
    );
  }
}
