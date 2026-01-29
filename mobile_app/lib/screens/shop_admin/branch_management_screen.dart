import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/models/branch_model.dart';

class BranchManagementScreen extends StatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppDataProvider>(context, listen: false).fetchBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);
    final branches = data.branches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branches',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton:
          Provider.of<AuthProvider>(context).role == 'branch_manager'
              ? null
              : FloatingActionButton(
                  onPressed: () => _showBranchDialog(context),
                  child: const Icon(Icons.add),
                ),
      body: branches.isEmpty
          ? const Center(
              child: Text('No branches found. Add your first branch!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return _buildBranchCard(context, branch);
              },
            ),
    );
  }

  Widget _buildBranchCard(BuildContext context, Branch branch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: branch.isActive
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          child: Icon(Icons.location_on_rounded,
              color: branch.isActive ? Colors.green : Colors.grey),
        ),
        title: Text(branch.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(branch.address ?? 'No address provided',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Provider.of<AuthProvider>(context, listen: false).role !=
                'branch_manager')
              Switch(
                value: branch.isActive,
                onChanged: (val) {
                  Provider.of<AppDataProvider>(context, listen: false)
                      .updateBranchStatus(branch.id, val);
                },
              ),
            if (Provider.of<AuthProvider>(context, listen: false).role !=
                'branch_manager')
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') {
                    _showBranchDialog(context, branch: branch);
                  } else if (val == 'assign') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Assign Manager feature coming soon!')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('View')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                      value: 'assign', child: Text('Assign Manager')),
                ],
              )
            else
              const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  void _showBranchDialog(BuildContext context, {Branch? branch}) {
    final nameController = TextEditingController(text: branch?.name);
    final addressController = TextEditingController(text: branch?.address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(branch == null ? 'Create Branch' : 'Edit Branch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Branch Name *')),
            TextField(
                controller: addressController,
                decoration:
                    const InputDecoration(labelText: 'Location / Address')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final navigator = Navigator.of(context);
              final provider =
                  Provider.of<AppDataProvider>(context, listen: false);
              bool success;
              if (branch == null) {
                success = await provider.createBranch({
                  'name': nameController.text,
                  'address': addressController.text,
                });
              } else {
                // Update logic... (Simplified for MVP)
                success = await provider.updateBranchStatus(
                    branch.id, branch.isActive);
              }

              if (!mounted) return;
              if (success) {
                navigator.pop();
              }
            },
            child: Text(branch == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }
}
