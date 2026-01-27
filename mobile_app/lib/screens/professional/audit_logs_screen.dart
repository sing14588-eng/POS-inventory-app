import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:intl/intl.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppDataProvider>(context, listen: false).fetchAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<AppDataProvider>(context);
    final logs = dataProvider.auditLogs;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Logs')),
      body: logs.isEmpty
          ? const Center(child: Text('No logs found'))
          : ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final log = logs[index];
                final date = DateFormat('MMM dd, HH:mm')
                    .format(DateTime.parse(log.createdAt));

                return ListTile(
                  isThreeLine: true,
                  leading: _buildActionIcon(log.action),
                  title: Text(log.action.replaceAll('_', ' ')),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.details ?? '',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('By: ${log.userName} • $date',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildActionIcon(String action) {
    IconData icon;
    Color color;

    if (action.contains('SALE')) {
      icon = Icons.shopping_basket;
      color = Colors.green;
    } else if (action.contains('PRODUCT')) {
      icon = Icons.inventory;
      color = Colors.blue;
    } else if (action.contains('REFUND')) {
      icon = Icons.replay;
      color = Colors.orange;
    } else {
      icon = Icons.info;
      color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
