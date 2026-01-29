import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';

class ProfessionalDrawer extends StatelessWidget {
  const ProfessionalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final data = Provider.of<AppDataProvider>(context);
    final role = auth.role;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(auth.name ?? 'User'),
            accountEmail:
                Text('${auth.branchName ?? "HQ"} - ${role?.toUpperCase()}'),
            currentAccountPicture: auth.currentCompany?.logoUrl.isNotEmpty ==
                    true
                ? CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(auth.currentCompany!.logoUrl),
                  )
                : const CircleAvatar(child: Icon(Icons.person)),
          ),
          if (role == 'admin' || role == 'accountant')
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Advanced Analytics'),
              onTap: () => Navigator.pushNamed(context, '/analytics'),
            ),
          if (role == 'admin' || role == 'warehouse')
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Supply Chain (Suppliers/PO)'),
              onTap: () => Navigator.pushNamed(context, '/suppliers'),
            ),
          if (role == 'admin')
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Activity Logs'),
              onTap: () => Navigator.pushNamed(context, '/audit-logs'),
            ),
          if (role == 'admin')
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Branch Management'),
              onTap: () => Navigator.pushNamed(context, '/branches'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: data.unreadNotifications > 0
                ? Badge(label: Text('${data.unreadNotifications}'))
                : null,
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          if (auth.roles.length > 1)
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
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
