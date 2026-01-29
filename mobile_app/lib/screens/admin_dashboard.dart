import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/auth_provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:pos_app/widgets/professional_drawer.dart';
import 'package:pos_app/widgets/security_notice.dart';
import 'package:pos_app/services/onboarding_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:pos_app/utils/app_theme.dart';
import 'package:pos_app/screens/audit_logs_screen.dart';
import 'package:pos_app/screens/branding_workshop_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _managementKey = GlobalKey();
  final GlobalKey _departmentsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = Provider.of<AppDataProvider>(context, listen: false);
      data.fetchDailyReport();
      data.fetchAnalytics();
      _checkOnboarding();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hello Manager! 👋'),
        content: const Text(
            'Welcome to your Shop Command Center. Would you like a 1-minute tour of your management tools?'),
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
      key: _statsKey,
      identify: "stats",
      title: "Live Snapshot",
      content:
          "Track your shop's revenue and performance metrics in real-time. This is your primary growth indicator.",
    ));

    targets.add(OnboardingService.createTarget(
      key: _managementKey,
      identify: "management",
      title: "Management Hub",
      content:
          "Manage your team, handle branch settings, and customize your business identity from this section.",
    ));

    targets.add(OnboardingService.createTarget(
      key: _departmentsKey,
      identify: "departments",
      title: "Department Views",
      content:
          "Switch between Sales, Inventory, and Audit logs to oversee every corner of your business.",
    ));

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.blueGrey[900]!,
      textSkip: "DONE",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () => Provider.of<AuthProvider>(context, listen: false)
          .completeOnboarding(),
      onSkip: () {
        Provider.of<AuthProvider>(context, listen: false).completeOnboarding();
        return true;
      },
    ).show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final company = authProvider.currentCompany;
    final companyName = company?.name ?? 'Admin Console';
    final brandColor = company != null
        ? AppTheme.hexToColor(company.primaryColor)
        : Colors.blue;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 100,
        leading: company?.logoUrl.isNotEmpty == true
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Hero(
                  tag: 'companyLogo',
                  child: Image.network(
                    company!.logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.business, color: Colors.blueGrey),
                  ),
                ),
              )
            : const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.storefront_rounded, color: Colors.blueGrey),
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(companyName,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.5,
                    color: Colors.black87)),
            Text('SHOP COMMAND CENTER',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: brandColor.withValues(alpha: 0.7))),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Consumer<AppDataProvider>(
            builder: (context, data, _) => IconButton(
              icon: Badge(
                label: data.unreadNotifications > 0
                    ? Text('${data.unreadNotifications}')
                    : null,
                isLabelVisible: data.unreadNotifications > 0,
                child: const Icon(Icons.notifications_none_rounded,
                    color: Colors.black87),
              ),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const ProfessionalDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              brandColor.withValues(alpha: 0.12),
              const Color(0xFFF8FAFC),
              const Color(0xFFF1F5F9),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(authProvider, brandColor),
                const SecurityNotice(),
                const SizedBox(height: 24),

                // Analytics Snapshot
                const Text('Live Snapshot',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey,
                        letterSpacing: 1.2)),
                const SizedBox(height: 12),
                _buildAnalyticsSnapshot(
                    context, _statsKey, company?.currencySymbol ?? '\$'),

                const SizedBox(height: 32),

                // Management Modules
                const Text('Management Modules',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey,
                        letterSpacing: 1.2)),
                const SizedBox(height: 16),
                _buildModuleSection(context, _managementKey),

                const SizedBox(height: 32),

                // Department Hotlinks
                const Text('Department Views',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey,
                        letterSpacing: 1.2)),
                const SizedBox(height: 12),
                _buildDepartmentLinks(context, _departmentsKey),

                const SizedBox(height: 40),
                _buildFooterInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(AuthProvider auth, Color brandColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Command Center',
                style: TextStyle(
                    fontSize: 13,
                    color: brandColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5))
            .animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.2),
        const SizedBox(height: 4),
        Text('Hello, ${auth.name?.split(' ')[0] ?? 'Admin'}!',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1))
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildAnalyticsSnapshot(
      BuildContext context, GlobalKey key, String currency) {
    return Consumer<AppDataProvider>(
      key: key,
      builder: (context, data, _) {
        final report = data.dailyReport;
        final revenue = report?['totalSales'] ?? 0.0;
        final txCount = report?['transactionCount'] ?? 0;

        return Row(
          children: [
            Expanded(
              child: _buildMiniStat(
                label: 'Today Revenue',
                value: '$currency$revenue',
                icon: Icons.auto_graph_rounded,
                color: Colors.green[600]!,
                trend: '+$txCount Tx',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniStat(
                label: 'System Status',
                value: 'Optimal',
                icon: Icons.security_rounded,
                color: Colors.blueAccent,
                trend: '99.9%',
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 400.ms)
            .scale(begin: const Offset(0.95, 0.95));
      },
    );
  }

  Widget _buildMiniStat(
      {required String label,
      required String value,
      required IconData icon,
      required Color color,
      required String trend}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(trend,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildModuleSection(BuildContext context, GlobalKey key) {
    return Column(
      key: key,
      children: [
        _buildModuleCard(
          context,
          title: 'Team & Access',
          desc: 'Manage roles, staff accounts & permissions',
          icon: Icons.group_add_rounded,
          color: Colors.indigo,
          onTap: () => Navigator.pushNamed(context, '/admin/users'),
        ),
        const SizedBox(height: 16),
        _buildModuleCard(
          context,
          title: 'Branding Workshop',
          desc: 'Customize your shop logo, colors & identity',
          icon: Icons.palette_rounded,
          color: Colors.pink,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => const BrandingWorkshopScreen())),
        ),
        const SizedBox(height: 16),
        _buildModuleCard(
          context,
          title: 'Executive Oversight',
          desc: 'Monitor all activities with detailed audit logs',
          icon: Icons.security_rounded,
          color: Colors.blueGrey[800]!,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (c) => const AuditLogsScreen())),
        ),
        const SizedBox(height: 16),
        _buildModuleCard(
          context,
          title: 'Branch Logistics',
          desc: 'Configure locations & branch settings',
          icon: Icons.storefront_rounded,
          color: Colors.orange[800]!,
          onTap: () => Navigator.pushNamed(context, '/admin/branches'),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildModuleCard(BuildContext context,
      {required String title,
      required String desc,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 10))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 13, height: 1.2)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentLinks(BuildContext context, GlobalKey key) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 24) / 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHotlink(context, 'Sales', Icons.point_of_sale_rounded,
                Colors.purple, '/sales', itemWidth),
            _buildHotlink(context, 'Inventory', Icons.inventory_rounded,
                Colors.blue, '/warehouse', itemWidth),
            _buildHotlink(context, 'Audits', Icons.fact_check_rounded,
                Colors.teal, '/audit', itemWidth),
          ],
        );
      },
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildHotlink(BuildContext context, String label, IconData icon,
      Color color, String route, double width) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.security_rounded, color: Colors.amber, size: 18),
            SizedBox(width: 8),
            Text('Security Status: Verified',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ]),
          const SizedBox(height: 12),
          Text(
            'All administrative actions are logged for audit purposes. End-to-end encryption is active for all module communications.',
            style:
                TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms);
  }
}
