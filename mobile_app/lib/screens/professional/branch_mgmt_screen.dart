import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';

class BranchMgmtScreen extends StatefulWidget {
  const BranchMgmtScreen({super.key});

  @override
  State<BranchMgmtScreen> createState() => _BranchMgmtScreenState();
}

class _BranchMgmtScreenState extends State<BranchMgmtScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppDataProvider>(context, listen: false).fetchBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<AppDataProvider>(context);
    final branches = dataProvider.branches;

    return Scaffold(
      appBar: AppBar(title: const Text('Branches')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBranchDialog(context),
        child: const Icon(Icons.add),
      ),
      body: branches.isEmpty
          ? const Center(child: Text('No branches found'))
          : ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final b = branches[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.location_on)),
                    title: Text(b.name),
                    subtitle: Text(b.address ?? 'No address provided'),
                    trailing: Switch(
                      value: b.isActive,
                      onChanged: (v) {
                        Provider.of<AppDataProvider>(context, listen: false)
                            .updateBranchStatus(b.id, v);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddBranchDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Branch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Branch Name')),
            TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final success =
                    await Provider.of<AppDataProvider>(context, listen: false)
                        .createBranch({
                  'name': nameController.text,
                  'address': addressController.text,
                });
                if (success && context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
