import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'diet_plan_screen.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diet & Exercise Charts',
              style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Track your nutrition and activity patterns',
              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),

          GeneticCtaBanner(
            icon: const Icon(Icons.assignment_outlined, color: AppTheme.primary),
            title: 'Your Personalized Diet & Exercise Plan',
            subtitle: 'AI-generated weekly plan tailored to your goals and genetic profile',
            buttonLabel: 'View My Plan',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DietPlanScreen())),
          ),

          // Date filter
          Row(
            children: [
              _dateBtn(Icons.chevron_left),
              const SizedBox(width: 12),
              Text('Apr 21 – 27',
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              _dateBtn(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: 20),

          _DietChart(),
          const SizedBox(height: 16),
          _ExerciseChart(),
          const SizedBox(height: 16),
          _NutritionSummary(),
        ],
      ),
    );
  }

  Widget _dateBtn(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Icon(icon, size: 16, color: AppTheme.textSecondary),
    );
  }
}

class _DietChart extends StatelessWidget {
  final days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final diet = const [
    [380.0, 620.0, 550.0],
    [420.0, 580.0, 600.0],
    [350.0, 640.0, 520.0],
    [400.0, 610.0, 580.0],
    [360.0, 590.0, 540.0],
    [440.0, 650.0, 610.0],
    [390.0, 600.0, 560.0],
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: 'Diet Chart', subtitle: 'Calorie intake breakdown — this week'),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 2000,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      getTitlesWidget: (val, _) => Text(
                        val.toInt().toString(),
                        style: GoogleFonts.dmSans(fontSize: 8, color: AppTheme.textMuted),
                      ),
                      reservedSize: 30,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final i = val.toInt();
                        if (i < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(days[i],
                                style: GoogleFonts.dmSans(fontSize: 9, color: AppTheme.textSecondary)),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.borderLight, strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  diet.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: diet[i][0] + diet[i][1] + diet[i][2],
                        color: Colors.transparent,
                        width: 22,
                        rodStackItems: [
                          BarChartRodStackItem(0, diet[i][2], const Color(0xFF8B3A00)),
                          BarChartRodStackItem(diet[i][2], diet[i][2] + diet[i][1], AppTheme.primary),
                          BarChartRodStackItem(diet[i][2] + diet[i][1], diet[i][0] + diet[i][1] + diet[i][2], const Color(0xFFFDD8B5)),
                        ],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _legendItem(const Color(0xFFFDD8B5), 'Breakfast'),
              const SizedBox(width: 14),
              _legendItem(AppTheme.primary, 'Lunch'),
              const SizedBox(width: 14),
              _legendItem(const Color(0xFF8B3A00), 'Dinner'),
            ],
          ),
          const SizedBox(height: 6),
          Text('Total weekly: 12,880 kcal',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _ExerciseChart extends StatelessWidget {
  final days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final exercise = const [35.0, 0.0, 50.0, 40.0, 0.0, 60.0, 30.0];

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(exercise.length, (i) => FlSpot(i.toDouble(), exercise[i]));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: 'Exercise Chart', subtitle: 'Activity minutes — this week'),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 70,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final i = val.toInt();
                        if (i < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(days[i],
                                style: GoogleFonts.dmSans(fontSize: 9, color: AppTheme.textSecondary)),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (val, _) => Text(
                        val.toInt().toString(),
                        style: GoogleFonts.dmSans(fontSize: 8, color: AppTheme.textMuted),
                      ),
                      reservedSize: 24,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.borderLight, strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primary,
                    barWidth: 2,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withOpacity(0.1),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionSummary extends StatelessWidget {
  final macros = const [
    ('Protein', '82g', 'target 90g', 0.91),
    ('Carbs', '210g', 'target 220g', 0.95),
    ('Fat', '58g', 'target 65g', 0.89),
    ('Fiber', '24g', 'target 30g', 0.80),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: 'Nutrition Summary', subtitle: 'Macro breakdown for today'),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: macros.map((m) => AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.$1, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 4),
                  Text(m.$2, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 17)),
                  Text(m.$3, style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.textMuted)),
                  const SizedBox(height: 6),
                  ProgressBar(percentage: m.$4),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}