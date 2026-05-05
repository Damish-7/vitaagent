import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'genetic_report_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health Reports',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Upload and analyze your medical documents',
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),

          // Genetic CTA
          GeneticCtaBanner(
            icon: const Icon(Icons.biotech_outlined, color: AppTheme.primary),
            title: 'Your Genetic Report',
            subtitle: 'Personalized nutrigenomics analysis based on your DNA',
            buttonLabel: 'View Full Report',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const GeneticReportScreen())),
          ),

          // Upload zone
          _UploadZone(),
          const SizedBox(height: 20),

          // Reports
          _ReportCard(
            title: 'Blood Test Report — March 2026',
            date: 'March 15, 2026',
            chips: const [
              'Hemoglobin: 13.8 g/dL',
              'Blood Sugar: 98 mg/dL',
              'Cholesterol: 178 mg/dL',
            ],
            note: 'Vijay parsed this report on Mar 16. All values within normal range.',
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Full Body Checkup — Jan 2026',
            date: 'January 8, 2026',
            chips: const [
              'BP: 118/76 mmHg',
              'BMI: 22.4',
              'Vitamin D: 28 ng/mL',
            ],
            note: 'Vijay flagged low Vitamin D. Supplement recommended.',
          ),
          const SizedBox(height: 28),

          // How it works
          Text('How it works',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _StepCard(
                      '1', 'Upload Report', 'Upload your medical documents in any format')),
              const SizedBox(width: 12),
              Expanded(
                  child: _StepCard(
                      '2', 'Agent Parses', 'Vijay extracts key health metrics automatically')),
              const SizedBox(width: 12),
              Expanded(
                  child: _StepCard(
                      '3', 'Data Saved', 'Results are stored in your clinical history')),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary, width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined,
                color: AppTheme.primary, size: 40),
            const SizedBox(height: 12),
            Text('Drop your report here or click to upload',
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('Supports PDF, JPG, PNG — Max 10MB',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Browse Files'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String date;
  final List<String> chips;
  final String note;

  const _ReportCard({
    required this.title,
    required this.date,
    required this.chips,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title,
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w500, fontSize: 15)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Analyzed',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.success)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(date,
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: chips
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(c,
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {},
            child: const Text('View Details'),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(note,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String num;
  final String title;
  final String desc;

  const _StepCard(this.num, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: AppTheme.primary, shape: BoxShape.circle),
            child: Center(
              child: Text(num,
                  style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
            ),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(desc,
              style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}