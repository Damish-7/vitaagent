import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final Map<String, String> _selected = {
    'breakfast': 'A',
    'snack1': 'A',
    'lunch': 'A',
    'snack2': 'A',
    'dinner': 'A',
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diet & Exercise Plan',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600)),
            Text('Aman · Week Apr 28, 2026',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          indicator: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: -8),
          tabs: const [Tab(text: 'Diet Plan'), Tab(text: 'Exercise Plan')],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _DietPlanTab(selected: _selected, onPick: (slot, opt) {
            setState(() => _selected[slot] = opt);
          }),
          const _ExercisePlanTab(),
        ],
      ),
    );
  }
}

class _DietPlanTab extends StatelessWidget {
  final Map<String, String> selected;
  final void Function(String slot, String opt) onPick;

  const _DietPlanTab({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _summaryChip('1800', 'Daily Calories', 'kcal'),
              _summaryChip('90', 'Protein', 'g'),
              _summaryChip('220', 'Carbs', 'g'),
              _summaryChip('65', 'Fat', 'g'),
            ],
          ),
          const SizedBox(height: 20),

          // Avoid/Prefer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Avoid', style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: ['White rice', 'Refined sugar', 'Fried snacks', 'Alcohol', 'Soda']
                          .map((c) => _chip(c, AppTheme.errorBg, AppTheme.error)).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prefer', style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: ['Quinoa', 'Lentils', 'Leafy greens', 'Greek yogurt', 'Nuts', 'Berries']
                          .map((c) => _chip(c, AppTheme.successBg, AppTheme.success)).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _MealSlot(
            id: 'breakfast', title: 'Breakfast', time: '7:30 AM',
            selected: selected['breakfast']!,
            onPick: (opt) => onPick('breakfast', opt),
            options: const [
              _MealOption(key: 'A', name: 'Quinoa Veggie Bowl', cal: '380 kcal', macros: 'P18g  C52g  F10g', rec: true),
              _MealOption(key: 'B', name: 'Whole wheat toast + PB + Banana', cal: '420 kcal', note: 'High energy for workouts'),
              _MealOption(key: 'C', name: 'Oats + Low-fat milk + Almonds + Honey', cal: '350 kcal', note: 'Stable blood sugar'),
            ],
          ),
          _MealSlot(
            id: 'lunch', title: 'Lunch', time: '1:00 PM',
            selected: selected['lunch']!,
            onPick: (opt) => onPick('lunch', opt),
            options: const [
              _MealOption(key: 'A', name: 'Grilled Chicken Mediterranean Bowl', cal: '520 kcal', macros: 'P42g  C48g  F14g', rec: true),
              _MealOption(key: 'B', name: 'Dal tadka + Multigrain roti 2 + Salad', cal: '480 kcal', note: 'Complete Indian meal'),
              _MealOption(key: 'C', name: 'Paneer tikka wrap + Mint chutney', cal: '450 kcal', note: 'Good vegetarian protein'),
            ],
          ),
          _MealSlot(
            id: 'dinner', title: 'Dinner', time: '8:00 PM',
            selected: selected['dinner']!,
            onPick: (opt) => onPick('dinner', opt),
            options: const [
              _MealOption(key: 'A', name: 'Baked Salmon + Stir-fried Vegetables', cal: '460 kcal', macros: 'P38g  C32g  F18g', rec: true),
              _MealOption(key: 'B', name: 'Moong dal soup + Brown bread 2 + Salad', cal: '380 kcal', note: 'Light, easy before sleep'),
              _MealOption(key: 'C', name: 'Tofu stir-fry + Small rice', cal: '400 kcal', note: 'Plant-based protein'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String val, String label, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Text(val, style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppTheme.primary, fontWeight: FontWeight.w600)),
          Text('$label ($unit)', style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

class _MealOption {
  final String key;
  final String name;
  final String cal;
  final String? macros;
  final String? note;
  final bool rec;

  const _MealOption({
    required this.key,
    required this.name,
    required this.cal,
    this.macros,
    this.note,
    this.rec = false,
  });
}

class _MealSlot extends StatelessWidget {
  final String id;
  final String title;
  final String time;
  final String selected;
  final List<_MealOption> options;
  final void Function(String) onPick;

  const _MealSlot({
    required this.id,
    required this.title,
    required this.time,
    required this.selected,
    required this.options,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(time, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        ...options.map((opt) {
          final isSel = selected == opt.key;
          return GestureDetector(
            onTap: () => onPick(opt.key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSel ? AppTheme.primaryLight : (opt.rec ? AppTheme.primaryLight.withOpacity(0.5) : AppTheme.surface),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSel ? AppTheme.primary : AppTheme.border,
                  width: isSel ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (opt.rec) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('Recommended', style: GoogleFonts.dmSans(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.star, color: AppTheme.primary, size: 13),
                            ],
                          ],
                        ),
                        if (opt.rec) const SizedBox(height: 6),
                        Text(opt.name, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14)),
                        const SizedBox(height: 3),
                        Text(opt.cal, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted)),
                        if (opt.macros != null)
                          Text(opt.macros!, style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textSecondary)),
                        if (opt.note != null)
                          Text(opt.note!, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  Radio<String>(
                    value: opt.key,
                    groupValue: selected,
                    onChanged: (v) => onPick(v!),
                    activeColor: AppTheme.primary,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _ExercisePlanTab extends StatefulWidget {
  const _ExercisePlanTab();

  @override
  State<_ExercisePlanTab> createState() => _ExercisePlanTabState();
}

class _ExercisePlanTabState extends State<_ExercisePlanTab> {
  int _day = 0;
  final Map<int, String> _exSel = {0: 'A', 1: 'A', 2: 'A', 3: 'A', 4: 'A', 5: 'A'};

  final calDays = const [
    ('Mon', '28'), ('Tue', '29'), ('Wed', '30'), ('Thu', '1'),
    ('Fri', '2'), ('Sat', '3'), ('Sun', '4'),
  ];

  final exData = const [
    [('A', 'Morning Run', '40 min', 'Moderate', '320 kcal', true, 'Steady-paced running to build endurance.'),
     ('B', 'Cycling', '45 min', 'Low', '260 kcal', false, 'Stationary or outdoor cycling at comfortable pace.'),
     ('C', 'Walk + Yoga', '50 min', 'Low', '200 kcal', false, '20 min easy walking followed by 30 min gentle yoga.')],
    [('A', 'Upper Body Strength', '45 min', 'High', '380 kcal', true, 'Bench press, rows, pull-ups, shoulder press.'),
     ('B', 'Resistance Bands', '40 min', 'Moderate', '300 kcal', false, 'Full upper body using bands.'),
     ('C', 'Pilates', '45 min', 'Low', '220 kcal', false, 'Controlled core-focused movements.')],
    [('A', 'Yoga Flow', '30 min', 'Low', '140 kcal', true, 'Dynamic yoga sequence with focus on flexibility.'),
     ('B', 'Foam Roll + Stretch', '20 min', 'Low', '80 kcal', false, 'Self-myofascial release using foam roller.'),
     ('C', 'Complete Rest', '-', 'Low', '0 kcal', false, 'Total rest day. Focus on hydration and sleep.')],
    [('A', 'HIIT Circuit', '30 min', 'High', '420 kcal', true, 'High-intensity interval training: 40 sec work / 20 sec rest.'),
     ('B', 'Functional Training', '40 min', 'Moderate', '340 kcal', false, 'Compound movements using dumbbells.'),
     ('C', 'Jump Rope + Core', '35 min', 'Moderate', '300 kcal', false, '10 min jump rope intervals + 25 min core work.')],
    [('A', 'Lower Body Strength', '45 min', 'High', '360 kcal', true, 'Squats, deadlifts, leg press, lunges.'),
     ('B', 'Swimming', '40 min', 'Moderate', '320 kcal', false, 'Full-body cardio workout.'),
     ('C', 'Dance / Zumba', '45 min', 'Moderate', '280 kcal', false, 'High-energy dance workout.')],
    [('A', 'Long Run', '60 min', 'Moderate', '480 kcal', true, 'Build aerobic base with steady 60-minute run.'),
     ('B', 'Group Sports', '60 min', 'High', '500 kcal', false, 'Basketball, tennis, badminton, or football.'),
     ('C', 'Trek / Long Walk', '90 min', 'Low', '350 kcal', false, 'Low-intensity outdoor hiking or brisk walking.')],
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10, runSpacing: 10,
            children: [
              _summaryChip('5', 'Sessions', '/week'),
              _summaryChip('45', 'Avg Duration', 'min'),
              _summaryChip('~1800', 'Weekly Burn', 'kcal'),
            ],
          ),
          const SizedBox(height: 20),

          // Calendar row
          Row(
            children: List.generate(7, (i) {
              final isActive = _day == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _day = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isActive ? AppTheme.primary : AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        Text(calDays[i].$1,
                            style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isActive ? Colors.white : AppTheme.textMuted)),
                        Text(calDays[i].$2,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          if (_day == 6)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryBorder),
              ),
              child: Column(
                children: [
                  Text('Rest Day', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Recovery and hydration. Light stretching if desired. Focus on sleep quality.',
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center),
                ],
              ),
            )
          else
            ...exData[_day].map((opt) {
              final isSel = _exSel[_day] == opt.$1;
              final intensityColor = opt.$4 == 'High' ? AppTheme.error : opt.$4 == 'Moderate' ? AppTheme.warning : AppTheme.success;
              return GestureDetector(
                onTap: () => setState(() => _exSel[_day] = opt.$1),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSel ? AppTheme.primaryLight : (opt.$6 ? AppTheme.primaryLight.withOpacity(0.4) : AppTheme.surface),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? AppTheme.primary : AppTheme.border, width: isSel ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (opt.$6) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                                  child: Text('Recommended', style: GoogleFonts.dmSans(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.star, color: AppTheme.primary, size: 13),
                              ],
                            ],
                          ),
                          Radio<String>(
                            value: opt.$1,
                            groupValue: _exSel[_day]!,
                            onChanged: (v) => setState(() => _exSel[_day] = v!),
                            activeColor: AppTheme.primary,
                          ),
                        ],
                      ),
                      Text(opt.$2, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 14)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6, runSpacing: 4,
                        children: [
                          _chip(opt.$3, AppTheme.borderLight, AppTheme.textSecondary),
                          _intensityChip(opt.$4, intensityColor),
                          _chip(opt.$5, AppTheme.borderLight, AppTheme.textSecondary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(opt.$7, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _summaryChip(String val, String label, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(val, style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppTheme.primary, fontWeight: FontWeight.w600)),
          Text('$label ($unit)', style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: fg)),
    );
  }

  Widget _intensityChip(String label, Color color) {
    final bg = color.withOpacity(0.15);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 9, color: color, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
    );
  }
}