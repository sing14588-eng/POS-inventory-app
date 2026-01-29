import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';

class StaffEditScreen extends StatefulWidget {
  const StaffEditScreen({super.key});

  @override
  State<StaffEditScreen> createState() => _StaffEditScreenState();
}

class _StaffEditScreenState extends State<StaffEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final Set<String> _selectedRoles = {'sales'};
  String? _selectedBranchId;

  bool _isLoading = false;
  Map<String, dynamic>? _generatedCredentials;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppDataProvider>(context, listen: false).fetchBranches();
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one role')),
      );
      return;
    }

    if (_selectedRoles.contains('branch_manager') &&
        _selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Branch is required for Branch Managers')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<AppDataProvider>(context, listen: false);

    // Logic for auto-generating username and password
    final tempPassword =
        "FLW${DateTime.now().millisecond}${100 + (DateTime.now().microsecond % 899)}";
    final usernameCode =
        "USR-${_nameController.text.substring(0, 3).toUpperCase()}-${DateTime.now().millisecond}";

    final userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'username': usernameCode,
      'password': tempPassword,
      'roles': _selectedRoles.toList(),
      'branch': _selectedBranchId,
    };

    try {
      final result = await provider.createUser(userData);
      if (!mounted) return;
      if (result != null) {
        setState(() {
          _generatedCredentials = {
            'username': usernameCode,
            'password': tempPassword,
          };
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create staff')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_generatedCredentials != null) {
      return _buildSuccessView();
    }

    final branches = Provider.of<AppDataProvider>(context).branches;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Staff')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email Address (Optional)',
                    prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 24),
              const Text('Assigned Roles (Select at least one)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...[
                'sales',
                'picker',
                'warehouse',
                'accountant',
                'branch_manager'
              ].map((role) {
                final isSelected = _selectedRoles.contains(role);
                return CheckboxListTile(
                  title: Text(role.toUpperCase().replaceAll('_', ' ')),
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedRoles.add(role);
                      } else {
                        _selectedRoles.remove(role);
                      }
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
              if (_selectedRoles.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 8),
                  child: Text('Please select at least one role',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              if (_selectedRoles.contains('branch_manager'))
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    "Branch Managers can only view and manage their assigned branch.",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedBranchId,
                decoration: const InputDecoration(
                    labelText: 'Assigned Branch',
                    prefixIcon: Icon(Icons.store_outlined)),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Global / No Branch')),
                  ...branches.map((b) =>
                      DropdownMenuItem(value: b.id, child: Text(b.name))),
                ],
                onChanged: (v) => setState(() => _selectedBranchId = v),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CREATE STAFF ACCOUNT',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text('Account Created!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                  'Please share these credentials with the staff member. They will be shown ONLY ONCE for security.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              _buildCredentialBox(
                  'Username / Code', _generatedCredentials!['username']),
              const SizedBox(height: 16),
              _buildCredentialBox(
                  'Temporary Password', _generatedCredentials!['password']),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('I HAVE SAVED THESE CREDENTIALS',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Copied: $label'),
                        duration: const Duration(seconds: 2)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
