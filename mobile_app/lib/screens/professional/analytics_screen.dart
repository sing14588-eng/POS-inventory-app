import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/providers/app_data_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppDataProvider>(context, listen: false).fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<AppDataProvider>(context);
    final analytics = dataProvider.analytics;

    return Scaffold(
      appBar: AppBar(title: const Text('Business Analytics')),
      body: analytics == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('7-Day Sales Trend'),
                  _buildSalesTrendChart(analytics['salesTrend']),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Category Distribution (Stock Value)'),
                  _buildCategoryPieChart(analytics['categoryStats']),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Top 5 Products'),
                  _buildTopProductsList(analytics['topProducts']),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSalesTrendChart(List<dynamic> trend) {
    if (trend.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('No data')));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: trend.asMap().entries.map((e) {
                return FlSpot(
                    e.key.toDouble(), (e.value['total'] as num).toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                  show: true, color: Colors.blue.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(List<dynamic> stats) {
    if (stats.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('No data')));
    }

    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: stats.asMap().entries.map((e) {
            final double value = (e.value['value'] as num).toDouble();
            return PieChartSectionData(
              color: colors[e.key % colors.length],
              value: value,
              title: '${e.value['_id']}',
              radius: 60,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopProductsList(List<dynamic> products) {
    return Column(
      children: products
          .map((p) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.star)),
                  title: Text(p['_id']),
                  subtitle: Text('Quantity Sold: ${p['totalQty']}'),
                  trailing: Text('\$${p['revenue']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ))
          .toList(),
    );
  }
}
