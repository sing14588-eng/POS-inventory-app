import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:intl/intl.dart';

class AuditLogsScreen extends StatefulWidget {
  final bool showAppBar;
  const AuditLogsScreen({super.key, this.showAppBar = true});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppDataProvider>(context, listen: false).fetchAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppDataProvider>(context);
    final logs = provider.auditLogs
        .where((l) =>
            l.action.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (l.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();

    Widget body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search logs (action, description)...',
              prefixIcon: const Icon(Icons.search_rounded),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.fetchAuditLogs(),
            child: logs.isEmpty
                ? const Center(child: Text('No logs found'))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: _buildActionIcon(log.action),
                          title: Text(log.action,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.description ?? 'No description'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 12, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy HH:mm')
                                        .format(log.createdAt),
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[600]),
                                  ),
                                  if (log.companyName != null) ...[
                                    const SizedBox(width: 8),
                                    const Text('|',
                                        style: TextStyle(color: Colors.grey)),
                                    const SizedBox(width: 8),
                                    Text(log.companyName!,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ]
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACTIVITY LOGS',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                Provider.of<AppDataProvider>(context, listen: false)
                    .fetchAuditLogs(),
          )
        ],
      ),
      body: body,
    );
  }

  Widget _buildActionIcon(String action) {
    IconData icon;
    Color color;

    final act = action.toLowerCase();
    if (act.contains('create')) {
      icon = Icons.add_circle_rounded;
      color = Colors.green;
    } else if (act.contains('delete')) {
      icon = Icons.delete_forever_rounded;
      color = Colors.red;
    } else if (act.contains('update') || act.contains('edit')) {
      icon = Icons.edit_rounded;
      color = Colors.blue;
    } else if (act.contains('login')) {
      icon = Icons.login_rounded;
      color = Colors.orange;
    } else {
      icon = Icons.info_rounded;
      color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
