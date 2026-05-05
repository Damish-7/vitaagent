import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class GeneticReportScreen extends StatefulWidget {
  const GeneticReportScreen({super.key});

  @override
  State<GeneticReportScreen> createState() => _GeneticReportScreenState();
}

class _GeneticReportScreenState extends State<GeneticReportScreen> {
  int _tab = 0;
  final Set<String> _openAcc = {};

  final List<String> _tabs = [
    'Overview', 'Diet', 'Nutrition', 'Fitness',
    'Sleep', 'Allergies', 'Disease Risk', 'Digestive',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Genetic Health Report',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            Text('Aman · DNL1000001',
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(
                _tabs.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: _tab == i ? AppTheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _tab == i ? AppTheme.primary : Colors.transparent,
                        ),
                      ),
                      child: Text(_tabs[i],
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _tab == i
                                  ? Colors.white
                                  : AppTheme.textSecondary)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildTabContent(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildDiet();
      case 2:
        return _buildNutrition();
      case 3:
        return _buildFitness();
      case 4:
        return _buildSleep();
      case 5:
        return _buildAllergies();
      case 6:
        return _buildDiseaseRisk();
      case 7:
        return _buildDigestive();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverview() {
    final chips = ['Blood Group: O+', 'Age: 28', 'DNA Sample: Valid', 'Report: Apr 2026'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((c) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(c, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
          )).toList(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
            border: const Border(left: BorderSide(color: AppTheme.primary, width: 3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
          ),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.6),
              children: [
                TextSpan(text: 'What is Nutrigenomics?\n', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 13)),
                const TextSpan(text: 'Nutrigenomics studies how your genes interact with the nutrients you consume. By analyzing specific genetic markers, we can provide personalized dietary and lifestyle recommendations tailored to your unique DNA profile.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Key Highlights', style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _highlightCard('Low Lactose Sensitivity', 'Low'),
            _highlightCard('Vitamin D — Restricted Intake', 'High'),
            _highlightCard('High Endurance Potential', 'Advantage'),
            _highlightCard('Moderate Caffeine Sensitivity', 'Moderate'),
          ],
        ),
      ],
    );
  }

  Widget _highlightCard(String title, String level) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title,
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          LevelBadge(level: level),
        ],
      ),
    );
  }

  Widget _buildDiet() {
    final items = [
      ('Lactose Sensitivity', 3, 'Low', 'Moderate dairy okay. Choose low-fat options.'),
      ('Gluten Sensitivity', 4, 'Low', 'No intolerance. Whole grains beneficial.'),
      ('Caffeine Metabolism', 6, 'Moderate', 'Max 2 cups/day. Avoid after 3 PM.'),
      ('Carbohydrate Metabolism', 7, 'High', 'Prefer complex carbs. Avoid refined sugars.'),
      ('Fat Absorption', 5, 'Normal', 'Include Omega-3 rich foods.'),
      ('Alcohol Sensitivity', 8, 'High', 'Strictly limit alcohol intake.'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final score = item.$2;
        final pct = score / 10.0;
        final barColor = score <= 4 ? AppTheme.success : score <= 6 ? AppTheme.warning : AppTheme.error;
        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.$1, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13))),
                  LevelBadge(level: item.$3),
                ],
              ),
              const SizedBox(height: 4),
              Text('Score ${item.$2}/10', style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 6),
              ProgressBar(percentage: pct, color: barColor),
              const SizedBox(height: 8),
              Text(item.$4, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutrition() {
    final groups = [
      ('Vitamins', [
        ('Vitamin D', 'Restricted', 'Bone health, immunity', 'Sunlight, fish'),
        ('Vitamin B12', 'Normal', 'Energy, nerve function', 'Eggs, dairy'),
        ('Vitamin C', 'Enhanced', 'Antioxidant, skin health', 'Citrus, peppers'),
      ]),
      ('Minerals', [
        ('Iron', 'Normal', 'Oxygen transport, energy', 'Spinach, lentils'),
        ('Calcium', 'Enhanced', 'Bone density, muscles', 'Dairy, greens'),
        ('Magnesium', 'Restricted', 'Sleep, muscle relaxation', 'Nuts, seeds'),
      ]),
      ('Fats', [
        ('Omega-3', 'Restricted', 'Heart and brain health', 'Salmon, walnuts'),
        ('Omega-6', 'Enhanced', 'Inflammation balance', 'Sunflower, soy'),
      ]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.expand((g) => [
        SectionLabel(label: g.$1),
        ...g.$2.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
            ),
            child: Row(
              children: [
                SizedBox(width: 100, child: Text(item.$1, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14))),
                LevelBadge(level: item.$2),
                const SizedBox(width: 10),
                Expanded(child: Text(item.$3, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(20)),
                  child: Text(item.$4, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ),
        )),
      ]).toList(),
    );
  }

  Widget _buildFitness() {
    final items = [
      (Icons.bolt_outlined, 'Recovery Ability', 'High', 'Fast muscle recovery. Train consecutive days.'),
      (Icons.wb_sunny_outlined, 'Optimal Exercise Time', 'Morning', 'Peak cortisol. High intensity works best.'),
      (Icons.bar_chart, 'Exercise Type', 'Mixed', 'Balanced fast/slow-twitch fibers.'),
      (Icons.shield_outlined, 'Injury Risk', 'Low', 'Low predisposition to soft tissue injuries.'),
      (Icons.trending_up, 'Endurance Capacity', 'High', 'Strong VO2 max. Running and cycling ideal.'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                child: Icon(item.$1, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(item.$2, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13))),
                      LevelBadge(level: item.$3),
                    ]),
                    const SizedBox(height: 6),
                    Text(item.$4, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSleep() {
    final items = [
      ('Sleep Cycle', 'Maintain consistent sleep/wake times. No blue light 1hr before bed.'),
      ('Deep Sleep Quality', 'Lighter deep sleep phases. Magnesium supplement may help.'),
      ('Circadian Rhythm', '10 min morning light exposure resets your natural clock.'),
    ];

    return Column(
      children: items.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
          border: const Border(left: BorderSide(color: AppTheme.primary, width: 3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.nights_stay_outlined, color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$1, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(item.$2, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildAllergies() {
    final groups = [
      ('High Risk', AppTheme.error, ['Dust', 'Pollen']),
      ('Moderate Risk', AppTheme.warning, ['Pet Dander', 'Mold', 'Nickel']),
      ('Low Risk', AppTheme.success, ['Gluten', 'Shellfish', 'Latex']),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.expand((g) => [
        SectionLabel(label: g.$1),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: g.$3.map((name) => Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border(top: BorderSide(color: g.$2, width: 3), left: BorderSide(color: AppTheme.border), right: BorderSide(color: AppTheme.border), bottom: BorderSide(color: AppTheme.border)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(height: 4),
                LevelBadge(level: g.$1.split(' ').first),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
      ]).toList(),
    );
  }

  Widget _buildDiseaseRisk() {
    final items = [
      ('heart', 'Heart', 'Moderate', [('Avoid', 'Saturated fats, excess sodium'), ('Follow', '30 min cardio 5x/week'), ('Consume', 'Omega-3, leafy greens'), ('Monitor', 'Blood pressure monthly')]),
      ('diabetes', 'Diabetes', 'Low', [('Avoid', 'Refined sugar, sugary drinks'), ('Follow', 'Consistent meal timing'), ('Consume', 'High-fiber foods, cinnamon'), ('Monitor', 'Fasting sugar annually')]),
      ('bone', 'Bone', 'Low', [('Avoid', 'Excess caffeine, soda'), ('Follow', 'Weight-bearing exercise'), ('Consume', 'Calcium, Vitamin D, K2'), ('Monitor', 'Bone density every 2 years')]),
      ('liver', 'Liver', 'Low', [('Avoid', 'Alcohol, processed oils'), ('Follow', 'Adequate hydration daily'), ('Consume', 'Turmeric, garlic'), ('Monitor', 'Liver enzymes annually')]),
    ];

    return Column(
      children: items.map((d) {
        final isOpen = _openAcc.contains(d.$1);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() {
                    if (isOpen) _openAcc.remove(d.$1); else _openAcc.add(d.$1);
                  }),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(d.$2, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14)),
                        const SizedBox(width: 10),
                        LevelBadge(level: d.$3),
                        const Spacer(),
                        Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.textMuted),
                      ],
                    ),
                  ),
                ),
                if (isOpen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 6,
                      childAspectRatio: 3,
                      children: d.$4.map((item) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 52,
                            child: Text(item.$1,
                                style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                          ),
                          Expanded(
                            child: Text(item.$2,
                                style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
                          ),
                        ],
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDigestive() {
    final items = [
      ('Lactose Intolerance', 'Low', 'Can tolerate moderate dairy. Try Greek yogurt.'),
      ('IBS Tendency', 'Moderate', 'Avoid raw onions. Low-FODMAP on flare days.'),
      ('Gut Microbiome', 'High', 'Include kefir, kimchi, yogurt daily.'),
      ('Bloating', 'Moderate', 'Eat slowly. Avoid carbonated drinks.'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(item.$1, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13))),
                LevelBadge(level: item.$2),
              ]),
              const SizedBox(height: 8),
              Text(item.$3, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
            ],
          ),
        );
      },
    );
  }
}