import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/models/company_model.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pos_app/services/api_service.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/screens/super_admin_settings_screen.dart';
import 'package:pos_app/screens/audit_logs_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _currentIndex = 0; // 0: Dashboard, 1: Shops, 2: Logs, 3: Settings
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);
      provider.fetchCompanies();
      provider.fetchGlobalStats();
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    // Note: In a full app, this would update a ThemeProvider
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppDataProvider>(context);
    final stats = provider.globalStats;

    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getPageTitle(),
              style: const TextStyle(
                  fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          actions: [
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(
                  _isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: _isDarkMode ? Colors.orange : Colors.indigo),
              tooltip: 'Toggle Theme',
            ),
            const SizedBox(width: 8),
          ],
        ),
        drawer: _buildDrawer(),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboard(stats),
            _buildShops(provider),
            _buildLogs(provider),
            _buildSettings(),
          ],
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'FLOWPOS HUB';
      case 1:
        return 'MANAGED SHOPS';
      case 2:
        return 'SECURITY LOGS';
      case 3:
        return 'SYSTEM SETTINGS';
      default:
        return 'FLOWPOS';
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey[900]),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings_rounded,
                      size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text('SUPER ADMIN',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),
          ),
          _buildDrawerItem(0, 'Dashboard', Icons.dashboard_rounded),
          _buildDrawerItem(1, 'Shops', Icons.store_rounded),
          _buildDrawerItem(2, 'Logs', Icons.receipt_long_rounded),
          _buildDrawerItem(3, 'Settings', Icons.settings_rounded),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Logout',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, String title, IconData icon) {
    bool isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : null),
      title: Text(title,
          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
      selected: isSelected,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDashboard(Map<String, dynamic>? stats) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<AppDataProvider>(context, listen: false)
          .fetchGlobalStats(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildSectionHeader('Platform Pulse', Icons.bolt_rounded),
          const SizedBox(height: 16),
          _buildPlatformStatus(),
          const SizedBox(height: 24),
          if (stats != null) ...[
            _buildStatCard(
                'Total Shops', stats['companyCount'].toString(), Colors.blue),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard('Active',
                        stats['activeCompanies'].toString(), Colors.green)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard('Deactivated',
                        stats['inactiveCompanies'].toString(), Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard('Total Sales (Live)',
                '\$${stats['totalRevenue'] ?? 0}', Colors.orange,
                isLarge: true),
          ] else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color,
      {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: isLarge ? 32 : 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildShops(AppDataProvider provider) {
    // Re-use logic for search and list from original dashboard but updated to spec
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                  child: _buildSectionHeader(
                      'Shop Management', Icons.hub_rounded)),
              ElevatedButton.icon(
                onPressed: _showCreateCompanyDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Shop'),
              ),
            ],
          ),
        ),
        // Filter/Search and List implementation would go here (similar to original code but simplified)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: provider.companies.length,
            itemBuilder: (context, index) =>
                _buildCompanyCard(provider.companies[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildLogs(AppDataProvider provider) {
    return const AuditLogsScreen(showAppBar: false);
  }

  Widget _buildSettings() {
    return const SuperAdminSettingsScreen();
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.blueGrey)),
      ],
    );
  }

  Widget _buildPlatformStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
          SizedBox(width: 12),
          Text('SYSTEMS OPERATIONAL',
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Spacer(),
          Text('LIVE',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper widget to build the credit dialogs or shop creation dialogs...
  // (Assuming _showCreateCompanyDialog and _buildCompanyCard are maintained/adapted from original code)

  void _showCreateCompanyDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    Color primaryColor = const Color(0xFF6C63FF);
    Color secondaryColor = const Color(0xFF4B4B4B);
    String? logoUrl;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Shop'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Shop Name *'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Admin Email *'),
                ),
                const SizedBox(height: 20),
                const Text('Business Logo *',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() => isUploading = true);
                      try {
                        final url = await ApiService().uploadImage(image.path);
                        setDialogState(() {
                          logoUrl = url;
                          isUploading = false;
                        });
                      } catch (e) {
                        setDialogState(() => isUploading = false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      image: (logoUrl != null && logoUrl!.startsWith('http'))
                          ? DecorationImage(
                              image: NetworkImage(logoUrl!),
                              fit: BoxFit.contain)
                          : null,
                    ),
                    child: isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : (logoUrl == null || !logoUrl!.startsWith('http'))
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.grey),
                                  Text('Tap to select logo',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setDialogState(() => logoUrl = v),
                  decoration: const InputDecoration(
                    labelText: 'Or Paste Logo URL',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const Text('Brand Colors',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildColorPreview(
                        'Primary',
                        primaryColor,
                        (color) => setDialogState(() => primaryColor = color),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildColorPreview(
                        'Secondary',
                        secondaryColor,
                        (color) => setDialogState(() => secondaryColor = color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const ListTile(
                  leading: Icon(Icons.payments_rounded, color: Colors.green),
                  title: Text('Currency Defaulted to: Birr'),
                  subtitle: Text('Ethiopia (ETB)'),
                ),
                const ListTile(
                  leading:
                      Icon(Icons.verified_user_rounded, color: Colors.blue),
                  title: Text('Standard MVP Plan'),
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
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    logoUrl == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please fill all mandatory fields'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                final response =
                    await Provider.of<AppDataProvider>(context, listen: false)
                        .createCompany({
                  'name': nameController.text,
                  'email': emailController.text,
                  'logoUrl': logoUrl,
                  'primaryColor':
                      '#${primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                  'secondaryColor':
                      '#${secondaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                });

                if (response != null && context.mounted) {
                  Navigator.pop(context);
                  _showCredentialsDialog(response['teamCredentials']);
                }
              },
              child: const Text('Create Shop'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview(String label, Color color, Function(Color) onPick) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Pick $label Color'),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: color,
                    onColorChanged: onPick,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyCard(Company company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage:
              company.logoUrl.isNotEmpty ? NetworkImage(company.logoUrl) : null,
          child:
              company.logoUrl.isEmpty ? const Icon(Icons.store_rounded) : null,
        ),
        title: Text(company.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'ID: ${company.id.length > 8 ? company.id.substring(0, 8) : company.id} | ${company.plan.toUpperCase()}'),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') {
              _showEditCompanyDialog(company);
            } else if (val == 'status') {
              Provider.of<AppDataProvider>(context, listen: false)
                  .updateCompanyStatus(company.id, !company.isActive);
            } else if (val == 'reset') {
              _confirmResetPassword(company);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit Shop')),
            PopupMenuItem(
                value: 'status',
                child: Text(company.isActive ? 'Deactivate' : 'Activate')),
            const PopupMenuItem(
                value: 'reset', child: Text('Reset Admin Password')),
          ],
        ),
        onTap: () => _showCompanyManagementSheet(company),
      ),
    );
  }

  void _showCredentialsDialog(Map<String, dynamic> team) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DefaultTabController(
        length: 3,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28))),
            child: const Column(
              children: [
                Icon(Icons.hub_rounded, size: 40, color: Colors.white),
                SizedBox(height: 12),
                Text('Starter Team Provisioned!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: 'ADMIN'),
                    Tab(text: 'SALES'),
                    Tab(text: 'WARE'),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: TabBarView(
                    children: [
                      _buildTeamRolePanel('ADMINISTRATOR', team['admin']),
                      _buildTeamRolePanel('SALES STAFF', team['sales']),
                      _buildTeamRolePanel('WAREHOUSE STAFF', team['warehouse']),
                    ],
                  ),
                ),
                const Text(
                  'Passwords will be forced to change upon first login.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[900],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('I HAVE SECURED THE TEAM',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRolePanel(String label, Map<String, dynamic> creds) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.blueGrey)),
        const SizedBox(height: 16),
        _buildCredentialRow('USERNAME', creds['username']),
        const SizedBox(height: 12),
        _buildCredentialRow('PASSWORD', creds['password']),
      ],
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey,
                        letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: Colors.black)),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('$label copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.blueGrey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 1),
                ));
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.copy_rounded, size: 20, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCompanyDialog(Company company) {
    final nameController = TextEditingController(text: company.name);
    final emailController = TextEditingController(text: company.email);
    final currencyController =
        TextEditingController(text: company.currencySymbol);
    String plan = company.plan;
    Color pickedColor = AppTheme.hexToColor(company.primaryColor);
    String? logoUrl = company.logoUrl;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${company.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Shop Name *'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Admin Email *'),
                ),
                const SizedBox(height: 20),
                const Text('Business Logo *',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() => isUploading = true);
                      final url = await ApiService().uploadImage(image.path);
                      setDialogState(() {
                        logoUrl = url;
                        isUploading = false;
                      });
                    }
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      image: logoUrl != null && logoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(logoUrl!),
                              fit: BoxFit.contain)
                          : null,
                    ),
                    child: isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : (logoUrl == null || logoUrl!.isEmpty)
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.grey),
                                  Text('Tap to select logo',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: logoUrl)
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: logoUrl?.length ?? 0)),
                  onChanged: (v) => setDialogState(() => logoUrl = v),
                  decoration: const InputDecoration(
                    labelText: 'Or Paste Logo URL',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Brand Color *',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pick Brand Color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: pickedColor,
                            onColorChanged: (color) => pickedColor = color,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setDialogState(() {});
                              Navigator.pop(context);
                            },
                            child: const Text('Select'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: pickedColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child: Text('Tap to change color',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: currencyController,
                  decoration:
                      const InputDecoration(labelText: 'Currency Symbol *'),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: plan,
                  isExpanded: true,
                  items: ['basic', 'premium', 'enterprise']
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text(e.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setDialogState(() => plan = v!),
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
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    logoUrl == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please fill all mandatory fields'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                final success =
                    await Provider.of<AppDataProvider>(context, listen: false)
                        .updateCompany(company.id, {
                  'name': nameController.text,
                  'email': emailController.text,
                  'plan': plan,
                  'logoUrl': logoUrl,
                  'primaryColor':
                      '#${pickedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                  'currencySymbol': currencyController.text,
                });
                if (success && context.mounted) Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompanyManagementSheet(Company company) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.hexToColor(company.primaryColor)
                      .withValues(alpha: 0.1),
                  backgroundImage: company.logoUrl.isNotEmpty
                      ? NetworkImage(company.logoUrl)
                      : null,
                  child: company.logoUrl.isEmpty
                      ? Icon(Icons.business,
                          color: AppTheme.hexToColor(company.primaryColor))
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(company.plan.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('MANAGEMENT ACTIONS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                    letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildActionTile(
              icon: Icons.edit_note_rounded,
              color: Colors.blue,
              title: 'Edit Shop Details',
              subtitle: 'Update name, logo, currency',
              onTap: () {
                Navigator.pop(context);
                _showEditCompanyDialog(company);
              },
            ),
            _buildActionTile(
              icon: Icons.vpn_key_rounded,
              color: Colors.orange,
              title: 'Reset Admin Password',
              subtitle: 'Generate new credentials',
              onTap: () {
                Navigator.pop(context);
                _confirmResetPassword(company);
              },
            ),
            _buildActionTile(
              icon: company.isActive
                  ? Icons.pause_circle_rounded
                  : Icons.play_circle_rounded,
              color: company.isActive ? Colors.amber : Colors.green,
              title:
                  company.isActive ? 'Suspend Operations' : 'Reactivate Shop',
              subtitle: company.isActive
                  ? 'Temporarily disable access'
                  : 'Restore full access',
              onTap: () {
                Navigator.pop(context);
                Provider.of<AppDataProvider>(context, listen: false)
                    .updateCompanyStatus(company.id, !company.isActive);
              },
            ),
            const Divider(height: 32),
            _buildActionTile(
              icon: Icons.delete_forever_rounded,
              color: Colors.red,
              title: 'Terminate Contract',
              subtitle: 'Permanently delete shop & data',
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteCompany(company);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _confirmResetPassword(Company company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password?'),
        content: Text(
            'This will generate a new password for the administrator of ${company.name}. The old password will stop working immediately.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await Provider.of<AppDataProvider>(context, listen: false)
                      .resetAdminPassword(company.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Password reset successful. Check email.')));
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCompany(Company company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Contract?'),
        content: Text(
            'This will permanently delete ${company.name} and all its data (sales, staff, inventory). This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Contract termination restricted to Root level.'),
                backgroundColor: Colors.red,
              ));
            },
            child: const Text('TERMINATE'),
          ),
        ],
      ),
    );
  }
}
