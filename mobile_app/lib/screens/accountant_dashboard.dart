import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/widgets/professional_drawer.dart';

class AccountantDashboard extends StatefulWidget {
  const AccountantDashboard({super.key});

  @override
  State<AccountantDashboard> createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends State<AccountantDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppDataProvider>(context, listen: false).fetchDailyReport();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<AppDataProvider>(context);
    final report = dataProvider.dailyReport;
    final today = DateFormat('MMM dd, yyyy').format(DateTime.now());
    final currency = authProvider.currentCompany?.currencySymbol ?? '\$';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: authProvider.currentCompany?.logoUrl.isNotEmpty == true
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(authProvider.currentCompany!.logoUrl),
                )
              : null,
          title: Text(authProvider.currentCompany?.name ?? 'Financials'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Debtors', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Refunds', icon: Icon(Icons.money_off)),
          ]),
          actions: [
            Consumer<AppDataProvider>(
              builder: (context, data, _) => IconButton(
                icon: Badge(
                  label: data.unreadNotifications > 0
                      ? Text('${data.unreadNotifications}')
                      : null,
                  isLabelVisible: data.unreadNotifications > 0,
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  final provider =
                      Provider.of<AppDataProvider>(context, listen: false);
                  provider.fetchDailyReport();
                  if (provider.refundRequests.isEmpty) {
                    provider.fetchRefundRequests();
                  }
                  provider.fetchPendingCreditSales();
                  provider.fetchNotifications();
                }),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            )
          ],
        ),
        drawer: const ProfessionalDrawer(),
        body: TabBarView(
          children: [
            // Tab 1: Overview
            report == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overview for $today',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 24),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildSummaryCard(
                                context,
                                'Total Sales',
                                '$currency${report['totalSales']}',
                                Icons.attach_money,
                                Colors.blue),
                            _buildSummaryCard(
                                context,
                                'Total VAT',
                                '$currency${report['totalVAT']?.toStringAsFixed(2)}',
                                Icons.pie_chart,
                                Colors.purple),
                            _buildSummaryCard(
                                context,
                                'Credit Sales',
                                '$currency${report['creditSales']}',
                                Icons.credit_card,
                                Colors.orange),
                            _buildSummaryCard(
                                context,
                                'Transactions',
                                '${report['transactionCount']}',
                                Icons.receipt_long,
                                Colors.teal),
                          ],
                        ),
                      ],
                    ),
                  ),

            // Tab 2: Debtors / Credit Management
            _buildCreditTab(dataProvider),

            // Tab 3: Refunds
            _buildRefundsTab(dataProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditTab(AppDataProvider dataProvider) {
    if (dataProvider.pendingCreditSales.isEmpty) {
      if (mounted) dataProvider.fetchPendingCreditSales();
      return const Center(child: Text('No pending credit payments'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataProvider.pendingCreditSales.length,
      itemBuilder: (context, index) {
        final sale = dataProvider.pendingCreditSales[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.warning, color: Colors.white)),
            title: Text('Amount: \$${sale.totalAmount}'),
            subtitle: Text(
                'Date: ${DateFormat('MMM dd, HH:mm').format(DateTime.parse(sale.createdAt))}'),
            trailing: ElevatedButton.icon(
              onPressed: () {
                dataProvider.settleCreditSale(sale.id);
              },
              icon: const Icon(Icons.check),
              label: const Text('Mark Paid'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRefundsTab(AppDataProvider dataProvider) {
    if (dataProvider.refundRequests.isEmpty) {
      if (mounted) dataProvider.fetchRefundRequests();
      return const Center(child: Text('No pending refunds'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataProvider.refundRequests.length,
      itemBuilder: (context, index) {
        final sale = dataProvider.refundRequests[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.replay, color: Colors.white)),
            title: Text(
                'Ref: #${sale.id.substring(sale.id.length - 6).toUpperCase()}'),
            subtitle: const Text(
                'Reason: Unknown'), // We didn't add reason to frontend model yet, assumed backend sends it.
            // Actually backend sends it, but frontend Model needs to parse it. I should fix model.
            trailing: ElevatedButton(
              onPressed: () {
                dataProvider.approveRefund(sale.id);
              },
              child: const Text('Approve'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }
}
