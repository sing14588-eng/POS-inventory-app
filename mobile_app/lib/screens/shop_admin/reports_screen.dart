import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _initialTab = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args.containsKey('tab')) {
      _initialTab = args['tab'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _initialTab,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports',
              style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Daily Sales'),
              Tab(text: 'Monthly Sales'),
              Tab(text: 'Credit Sales'),
              Tab(text: 'VAT Report'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailySalesReport(),
            _buildComingSoon('Monthly Sales'),
            _buildComingSoon('Credit Sales'),
            _buildComingSoon('VAT Reports'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: null, // Disabled as per Fix 4
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.grey[600],
          label: const Text('Export (Phase 2)'),
          icon: const Icon(Icons.download_rounded),
        ),
      ),
    );
  }

  Widget _buildDailySalesReport() {
    // For MVP, we'll use a simple Table with mock/static data or from provider if available
    // Assuming AppDataProvider has dailyReport data
    final stats = Provider.of<AppDataProvider>(context).shopAdminStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Today\'s Sales Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(
                color: Colors.grey[300]!,
                width: 1,
                borderRadius: BorderRadius.circular(8)),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.5),
            },
            children: [
              _buildTableHeader(['Date', 'Metric', 'Amount']),
              _buildTableRow(
                  ['Today', 'Total Sales', "${stats?['todaySales'] ?? 0}"]),
              _buildTableRow(['Today', 'Credit Sales', "0.00"]), // Mock for MVP
              _buildTableRow(['Today', 'VAT (15%)', "0.00"]), // Mock for MVP
            ],
          ),
          const SizedBox(height: 24),
          const Text('Filter by Date', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_rounded),
            label: const Text('Select Date (Daily Only)'),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader(List<String> cells) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[100]),
      children: cells
          .map((c) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text(c,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ))
          .toList(),
    );
  }

  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      children: cells
          .map((c) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text(c),
              ))
          .toList(),
    );
  }

  Widget _buildComingSoon(String reportName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty_rounded,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('$reportName – coming soon',
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('This feature is being finalized.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
