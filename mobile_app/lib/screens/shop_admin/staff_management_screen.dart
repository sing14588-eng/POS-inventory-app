import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppDataProvider>(context, listen: false);
      provider.fetchBranches();
      provider.fetchStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);
    final branches = data.branches;
    final staff = data.staff;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Staff', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/shop-admin/staff/add'),
        child: const Icon(Icons.person_add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedBranchId,
              decoration: InputDecoration(
                labelText: 'Filter by Branch',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('All Branches')),
                ...branches.map(
                    (b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
              ],
              onChanged: (v) => setState(() => _selectedBranchId = v),
            ),
          ),
          Expanded(
            child: staff.isEmpty
                ? const Center(child: Text('No staff found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: staff.length,
                    itemBuilder: (context, index) {
                      final member = staff[index];
                      // Simple local filter for MVP
                      if (_selectedBranchId != null &&
                          member.branchId != _selectedBranchId) {
                        return const SizedBox.shrink();
                      }
                      return _buildStaffCard(context, member);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, dynamic member) {
    // Determine roles list. Fallback to single role if generic list not present or empty
    List<String> roles = [];
    if (member.roles != null && (member.roles as List).isNotEmpty) {
      roles = List<String>.from(member.roles);
    } else {
      roles = [member.role ?? 'staff'];
    }

    final branchName = member.branchName ?? 'Global';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(child: Text(member.name[0].toUpperCase())),
        title: Text(member.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: roles.map((role) {
                Color roleColor = Colors.blue;
                if (role == 'branch_manager') roleColor = Colors.purple;
                if (role == 'picker') roleColor = Colors.orange;
                if (role == 'accountant') roleColor = Colors.teal;
                if (role == 'warehouse') roleColor = Colors.brown;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: roleColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(role.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                          color: roleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            Text("📍 $branchName",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Switch(
          value: member.isActive ?? true,
          onChanged: (v) async {
            final messenger = ScaffoldMessenger.of(context);
            final provider =
                Provider.of<AppDataProvider>(context, listen: false);
            final success = await provider.updateUserStatus(member.id, v);
            if (!mounted) return;

            if (!success) {
              messenger.showSnackBar(
                const SnackBar(content: Text('Failed to update status')),
              );
            }
          },
        ),
      ),
    );
  }
}
