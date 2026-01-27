import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/widgets/glass_container.dart';
import 'package:pos_app/models/company_model.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pos_app/services/api_service.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);
      provider.fetchCompanies();
      provider.fetchGlobalStats();
    });
  }

  void _showCreateCompanyDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final currencyController = TextEditingController(text: '\$');
    String plan = 'basic';
    Color pickedColor = const Color(0xFF6C63FF);
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
                      image: logoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(logoUrl!),
                              fit: BoxFit.contain)
                          : null,
                    ),
                    child: isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : logoUrl == null
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
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setDialogState(() => logoUrl = v),
                  decoration: const InputDecoration(
                    labelText: 'Or Paste Logo URL',
                    prefixIcon: Icon(Icons.link),
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
                        .createCompany({
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
              child: const Text('Create'),
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppDataProvider>(context);
    final stats = provider.globalStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          provider.fetchCompanies();
          provider.fetchGlobalStats();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Platform Overview',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (stats != null)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                        'Total Shops',
                        stats['companyCount'].toString(),
                        Icons.business,
                        Colors.blue),
                    _buildStatCard('Total Users', stats['userCount'].toString(),
                        Icons.people, Colors.orange),
                    _buildStatCard('Total Sales', '\$${stats['totalRevenue']}',
                        Icons.payments, Colors.green),
                    _buildStatCard(
                        'Total Products',
                        stats['productCount'].toString(),
                        Icons.inventory,
                        Colors.purple),
                  ],
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Managed Shops',
                      style: Theme.of(context).textTheme.titleLarge),
                  ElevatedButton.icon(
                    onPressed: _showCreateCompanyDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Shop'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (provider.isLoadingCompanies)
                const Center(child: CircularProgressIndicator())
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.companies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final company = provider.companies[index];
                    return _buildCompanyCard(company);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(Company company) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: company.isActive
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            child: Icon(Icons.store,
                color: company.isActive ? Colors.green : Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => _showEditCompanyDialog(company),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(company.email ?? 'No Email',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(company.plan.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          Switch(
            value: company.isActive,
            onChanged: (v) {
              Provider.of<AppDataProvider>(context, listen: false)
                  .updateCompanyStatus(company.id, v);
            },
          ),
        ],
      ),
    );
  }
}
