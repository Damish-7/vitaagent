import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ClinicalHistoryScreen extends StatelessWidget {
  const ClinicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      _TimelineEntry(
        date: 'March 15, 2026',
        title: 'Blood Test Report',
        summary: 'CBC normal. Hemoglobin 13.8 g/dL. Blood sugar within normal fasting range. Cholesterol optimal at 178 mg/dL. No medications required.',
      ),
      _TimelineEntry(
        date: 'January 8, 2026',
        title: 'Full Body Checkup',
        summary: 'BP excellent at 118/76. BMI healthy. Vitamin D deficiency noted (28 ng/mL). Supplement D3 2000 IU daily recommended. Follow up in 3 months.',
      ),
      _TimelineEntry(
        date: 'October 3, 2025',
        title: 'Dental Checkup',
        summary: 'No cavities. Minor plaque buildup. Advised professional cleaning every 6 months.',
      ),
      _TimelineEntry(
        date: 'July 20, 2025',
        title: 'Eye Examination',
        summary: 'Vision 6/6 both eyes. No correction required. No signs of strain or pressure issues.',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clinical History',
              style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('AI-generated timeline from your reports',
              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),

          // Patient card
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primary,
                  child: Text('RK',
                      style: GoogleFonts.dmSans(
                          color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aman',
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Age: 28  |  Blood Group: O+',
                          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          "Height 5'10\"", 'Weight 72kg', 'BMI 22.4', 'Last checkup: Mar 2026'
                        ].map((c) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(c,
                              style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textSecondary)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Timeline
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline bar
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryLight, width: 3),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.expand((e) => [
                      _buildTimelineEntry(e),
                      if (e != entries.last) const SizedBox(height: 24),
                    ]).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEntry(_TimelineEntry e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(e.date,
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(e.title,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 15)),
        const SizedBox(height: 6),
        Text(e.summary,
            style: GoogleFonts.dmSans(
                fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
      ],
    );
  }
}

class _TimelineEntry {
  final String date;
  final String title;
  final String summary;

  _TimelineEntry({required this.date, required this.title, required this.summary});

  @override
  bool operator ==(Object other) =>
      other is _TimelineEntry && other.date == date;

  @override
  int get hashCode => date.hashCode;
}