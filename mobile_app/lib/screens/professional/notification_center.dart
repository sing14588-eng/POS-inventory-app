import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:intl/intl.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppDataProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<AppDataProvider>(context);
    final notifications = dataProvider.notifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(child: Text('All caught up!'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                final date = DateFormat('MMM dd, HH:mm')
                    .format(DateTime.parse(n.createdAt));

                return Dismissible(
                  key: Key(n.id),
                  onDismissed: (_) {
                    dataProvider.markNotificationRead(n.id);
                  },
                  child: ListTile(
                    leading: _buildTypeIcon(n.type),
                    title: Text(n.title,
                        style: TextStyle(
                            fontWeight: n.isRead
                                ? FontWeight.normal
                                : FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.message),
                        const SizedBox(height: 4),
                        Text(date,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    tileColor:
                        n.isRead ? null : Colors.blue.withValues(alpha: 0.05),
                    onTap: () {
                      if (!n.isRead) {
                        dataProvider.markNotificationRead(n.id);
                      }
                      // Navigate based on data if exists
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'WARNING':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'ERROR':
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'SUCCESS':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.info;
        color = Colors.blue;
    }

    return Icon(icon, color: color);
  }
}
