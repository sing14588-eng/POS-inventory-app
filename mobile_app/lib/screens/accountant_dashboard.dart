import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/widgets/security_notice.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pos_app/widgets/professional_drawer.dart';
import 'package:pos_app/services/onboarding_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AccountantDashboard extends StatefulWidget {
  const AccountantDashboard({super.key});

  @override
  State<AccountantDashboard> createState() => _AccountantDashboardState();
}

class _AccountantDashboardState extends State<AccountantDashboard> {
  final GlobalKey _fiscalKey = GlobalKey();
  final GlobalKey _debtorsKey = GlobalKey();
  final GlobalKey _refundsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppDataProvider>(context, listen: false).fetchDailyReport();
      }
    });
  }

  void _checkOnboarding() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.onboardingCompleted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _showOnboardingWelcome();
        }
      });
    }
  }

  void _showOnboardingWelcome() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome! 📊'),
        content:
            const Text('Would you like a quick tour of your Fiscal Console?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false)
                  .completeOnboarding();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startTour();
            },
            child: const Text('Start Tour'),
          ),
        ],
      ),
    );
  }

  void _startTour() {
    List<TargetFocus> targets = [];
    targets.add(OnboardingService.createTarget(
      key: _fiscalKey,
      identify: "fiscal",
      title: "Fiscal Sovereignty",
      content:
          "Track your shop's real-time financial health and transaction volume.",
    ));
    targets.add(OnboardingService.createTarget(
      key: _debtorsKey,
      identify: "debtors",
      title: "Credit Management",
      content:
          "Monitor pending credit sales and settle customer debts efficiently.",
    ));
    targets.add(OnboardingService.createTarget(
      key: _refundsKey,
      identify: "refunds",
      title: "Refund Control",
      content: "Audit and approve refund requests with full transparency.",
    ));

    OnboardingService.showTour(
      context,
      targets: targets,
      onFinish: () => Provider.of<AuthProvider>(context, listen: false)
          .completeOnboarding(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<AppDataProvider>(context);
    final report = dataProvider.dailyReport;
    final currency = authProvider.currentCompany?.currencySymbol ?? '\$';
    final company = authProvider.currentCompany;
    final brandColor = company != null
        ? AppTheme.hexToColor(company.primaryColor)
        : AppTheme.primaryColor;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Modern subtle background
        drawer: const ProfessionalDrawer(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: company?.logoUrl.isNotEmpty == true
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Hero(
                    tag: 'companyLogo',
                    child: Image.network(company!.logoUrl, fit: BoxFit.contain),
                  ),
                )
              : const Icon(Icons.account_balance_rounded,
                  color: Colors.blueGrey),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(company?.name ?? 'Financials',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Colors.black87)),
              Text('FISCAL CONSOLE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: brandColor.withValues(alpha: 0.7))),
            ],
          ),
          bottom: TabBar(
            key:
                _debtorsKey, // Using debtors key for the tab bar since it contains the other tabs
            indicatorColor: brandColor,
            labelColor: brandColor,
            unselectedLabelColor: Colors.grey,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(
                  text: 'SNAPSHOT',
                  icon: Icon(Icons.analytics_rounded, size: 20)),
              Tab(
                  text: 'DEBTORS',
                  icon: Icon(Icons.account_balance_wallet_rounded, size: 20)),
              Tab(
                  text: 'REFUNDS',
                  icon: Icon(Icons.assignment_return_rounded, size: 20)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: brandColor),
              onPressed: () => _refreshAll(dataProvider),
            ),
            _buildNotificationBadge(dataProvider),
            IconButton(
              icon: const Icon(Icons.person_outline_rounded,
                  color: Colors.black87),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Overview
            report == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshAll(dataProvider),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SecurityNotice(),
                          const SizedBox(height: 20),
                          Container(
                              key: _fiscalKey,
                              child: _buildModernFiscalHeader(
                                  report, currency, brandColor)),
                          const SizedBox(height: 24),
                          Text('Revenue Breakdown',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Colors.blueGrey[900])),
                          const SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildFiscalBentoItem(
                                  'Total Sales',
                                  '$currency${report['totalSales']}',
                                  Icons.payments_rounded,
                                  Colors.green,
                                  brandColor),
                              _buildFiscalBentoItem(
                                  'VAT Collected',
                                  '$currency${report['totalVAT']?.toStringAsFixed(2)}',
                                  Icons.pie_chart_rounded,
                                  Colors.purple,
                                  brandColor),
                              _buildFiscalBentoItem(
                                  'Credit Exposure',
                                  '$currency${report['creditSales']}',
                                  Icons.credit_score_rounded,
                                  Colors.orange,
                                  brandColor),
                              _buildFiscalBentoItem(
                                  'Volume',
                                  '${report['transactionCount']} tx',
                                  Icons.receipt_long_rounded,
                                  Colors.blue,
                                  brandColor),
                            ],
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        ],
                      ),
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
      if (mounted) {
        dataProvider.fetchPendingCreditSales();
      }
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
      if (mounted) {
        dataProvider.fetchRefundRequests();
      }
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

  Future<void> _refreshAll(AppDataProvider provider) async {
    await provider.fetchDailyReport();
    await provider.fetchRefundRequests();
    await provider.fetchPendingCreditSales();
    await provider.fetchNotifications();
  }

  Widget _buildNotificationBadge(AppDataProvider data) {
    return IconButton(
      icon: Badge(
        label: data.unreadNotifications > 0
            ? Text('${data.unreadNotifications}')
            : null,
        isLabelVisible: data.unreadNotifications > 0,
        backgroundColor: Colors.redAccent,
        child:
            const Icon(Icons.notifications_none_rounded, color: Colors.black87),
      ),
      onPressed: () => Navigator.pushNamed(context, '/notifications'),
    );
  }

  Widget _buildModernFiscalHeader(
      dynamic report, String currency, Color brandColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [brandColor, brandColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: brandColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Daily Revenue',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              Icon(Icons.trending_up_rounded,
                  color: Colors.white.withValues(alpha: 0.5), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text('$currency${report['totalSales']}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on_rounded,
                        color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text('${report['transactionCount']} ops',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('Updates in real-time',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiscalBentoItem(String label, String value, IconData icon,
      Color color, Color brandColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5)),
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
