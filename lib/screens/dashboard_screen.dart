import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back, Aman 👋',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text("Here's your health summary for today — Apr 03, 2026",
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          _buildMetricsRow(),
          const SizedBox(height: 20),
          _buildWeeklyChart(),
          const SizedBox(height: 16),
          _buildTodayPlan(),
          const SizedBox(height: 16),
          _buildAgentCard(),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    final metrics = [
      _MetricData('Steps Today', '8,240', '/ 10,000', 0.82, null, null),
      _MetricData('Calories Burned', '420', 'kcal', null, 'up', '+8%'),
      _MetricData('Calories Consumed', '1,840', 'kcal', null, 'warn', 'vs 2,000 goal'),
      _MetricData('Water Intake', '1.8L', '/ 2.5L', 0.72, null, null),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final crossCount = constraints.maxWidth > 600 ? 4 : 2;
      return GridView.count(
        crossAxisCount: crossCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.4,
        children: metrics.map((m) => _MetricCard(data: m)).toList(),
      );
    });
  }

  Widget _buildWeeklyChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final steps = [7200.0, 9800.0, 6500.0, 10200.0, 8800.0, 4500.0, 8240.0];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(
              title: 'Weekly Activity', subtitle: 'Steps per day this week'),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 12000,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) => Text(
                        val > 0 ? '${(val / 1000).toStringAsFixed(0)}k' : '0',
                        style: GoogleFonts.dmSans(
                            fontSize: 9, color: AppTheme.textMuted),
                      ),
                      reservedSize: 30,
                      interval: 3000,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(days[idx],
                                style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: AppTheme.borderLight,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  steps.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: steps[i],
                        color: i == 6 ? AppTheme.primary : const Color(0xFFFEF0E6),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPlan() {
    final items = [
      _AgendaItem('08:00 AM', 'Morning walk (30 min)', true),
      _AgendaItem('01:00 PM', 'Lunch: Mediterranean bowl', false),
      _AgendaItem('06:30 PM', 'Strength training', false),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(
              title: "Today's Plan", subtitle: 'Scheduled activities'),
          const SizedBox(height: 12),
          ...items.map((item) => _AgendaRow(item: item)),
        ],
      ),
    );
  }

  Widget _buildAgentCard() {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.smart_toy_outlined,
                  color: AppTheme.primary, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vijay — Your Health Agent',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w500, fontSize: 15)),
                const SizedBox(height: 6),
                Text(
                  "Based on your activity this week, you're 12% above your step goal. Your calorie intake is balanced. I recommend increasing water intake by 0.7L today.",
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.6),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Ask Vijay'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final String target;
  final double? pct;
  final String? trend;
  final String? trendText;

  _MetricData(this.label, this.value, this.target, this.pct, this.trend,
      this.trendText);
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.label,
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          Text(data.value,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(data.target,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppTheme.textMuted)),
              if (data.trend == 'up') ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.successBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward,
                          size: 10, color: AppTheme.success),
                      Text(data.trendText!,
                          style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: AppTheme.success,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
              if (data.trend == 'warn') ...[
                const SizedBox(width: 6),
                Text(data.trendText!,
                    style: GoogleFonts.dmSans(
                        fontSize: 10, color: AppTheme.warning)),
              ],
            ],
          ),
          if (data.pct != null) ...[
            const SizedBox(height: 8),
            ProgressBar(percentage: data.pct!),
          ],
        ],
      ),
    );
  }
}

class _AgendaItem {
  final String time;
  final String text;
  final bool isGreen;

  _AgendaItem(this.time, this.text, this.isGreen);
}

class _AgendaRow extends StatelessWidget {
  final _AgendaItem item;

  const _AgendaRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: item.isGreen ? AppTheme.success : AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(item.time,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(item.text,
                style: GoogleFonts.dmSans(
                    fontSize: 14, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}