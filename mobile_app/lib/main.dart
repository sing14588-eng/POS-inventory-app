import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/screens/login_screen.dart';
import 'package:pos_app/screens/sales_dashboard.dart';
import 'package:pos_app/screens/picker_dashboard.dart';
import 'package:pos_app/screens/accountant_dashboard.dart';
import 'package:pos_app/screens/warehouse_dashboard.dart';
import 'package:pos_app/utils/app_theme.dart';

import 'package:pos_app/screens/admin_dashboard.dart';
import 'package:pos_app/screens/user_management_screen.dart';
import 'package:pos_app/screens/sales_history_screen.dart';
import 'package:pos_app/screens/role_selection_screen.dart';
import 'package:pos_app/services/offline_service.dart';
import 'package:pos_app/services/error_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: ErrorService.scaffoldMessengerKey,
      title: 'Inventory Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/sales': (context) => const SalesDashboard(),
        '/picker': (context) => const PickerDashboard(),
        '/accountant': (context) => const AccountantDashboard(),
        '/warehouse': (context) => const WarehouseDashboard(),
        '/admin': (context) => const AdminDashboard(),
        '/admin/users': (context) => const UserManagementScreen(),
        '/sales/history': (context) => const SalesHistoryScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
      },
    );
  }
}
