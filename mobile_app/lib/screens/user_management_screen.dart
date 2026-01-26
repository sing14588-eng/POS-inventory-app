import 'package:flutter/material.dart';
import 'package:pos_app/services/api_service.dart';
import 'package:pos_app/widgets/glass_container.dart';
import 'package:pos_app/utils/app_theme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // List view state
  bool _isLoadingList = true;
  List<dynamic> _users = [];

  // Form state
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isCreating = false;

  // Multi-select roles
  final List<String> _availableRoles = [
    'sales',
    'warehouse',
    'picker',
    'accountant',
    'admin'
  ];
  final List<String> _selectedRoles = ['sales'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoadingList = true);
    try {
      final data = await _apiService.get('/users');
      setState(() {
        _users = data;
        _isLoadingList = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingList = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching users: $e')));
      }
    }
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one role')));
      return;
    }

    setState(() => _isCreating = true);
    try {
      // Create user endpoint
      await _apiService.postAuth('/users', {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'roles': _selectedRoles,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User Created Successfully'),
            backgroundColor: Colors.green));
        _formKey.currentState?.reset();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _selectedRoles.clear();
        _selectedRoles.add('sales');
        _fetchUsers(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _toggleUserStatus(String id, bool currentStatus) async {
    try {
      await _apiService.put('/users/$id', {'isActive': !currentStatus});
      _fetchUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Team')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create User Section
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Team Member',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (v) => v!.length < 3 ? 'Min 3 chars' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Assign Roles:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: _availableRoles.map((role) {
                        final isSelected = _selectedRoles.contains(role);
                        return FilterChip(
                          label: Text(role.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedRoles.add(role);
                              } else {
                                _selectedRoles.remove(role);
                              }
                            });
                          },
                          selectedColor:
                              AppTheme.primaryColor.withValues(alpha: 0.2),
                          checkmarkColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isCreating ? null : _createUser,
                        icon: const Icon(Icons.add),
                        label: _isCreating
                            ? const CircularProgressIndicator()
                            : const Text('Create Account & Grant Access'),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16)),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text('Current Team',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            _isLoadingList
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final isActive = user['isActive'] ?? true;
                      final roles = List<String>.from(
                          user['roles'] ?? [user['role'] ?? 'unknown']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isActive ? Colors.green[100] : Colors.red[100],
                            child: Icon(isActive ? Icons.check : Icons.block,
                                color: isActive ? Colors.green : Colors.red),
                          ),
                          title: Text(user['name'],
                              style: TextStyle(
                                  decoration: isActive
                                      ? null
                                      : TextDecoration.lineThrough)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['email']),
                              const SizedBox(height: 4),
                              Wrap(
                                  spacing: 4,
                                  children: roles
                                      .map((r) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: Colors.blue[200]!)),
                                            child: Text(r.toUpperCase(),
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.blue)),
                                          ))
                                      .toList())
                            ],
                          ),
                          trailing: Switch(
                            value: isActive,
                            onChanged: (val) =>
                                _toggleUserStatus(user['_id'], isActive),
                            activeThumbColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            activeTrackColor: Colors.green[200],
                          ),
                        ),
                      );
                    },
                  )
          ],
        ),
      ),
    );
  }
}
