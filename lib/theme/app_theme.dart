import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFFCC5500);
  static const Color primaryDark = Color(0xFFA84400);
  static const Color primaryLight = Color(0xFFFEF6EF);
  static const Color primaryBorder = Color(0xFFF0C09A);
  static const Color background = Color(0xFFFDFAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8DDD5);
  static const Color borderLight = Color(0xFFF0E8E0);
  static const Color textPrimary = Color(0xFF1A1210);
  static const Color textSecondary = Color(0xFF6B5147);
  static const Color textMuted = Color(0xFFA08070);
  static const Color success = Color(0xFF2D7A4F);
  static const Color successBg = Color(0xFFE6F4ED);
  static const Color warning = Color(0xFFB85C00);
  static const Color warningBg = Color(0xFFFEF9E6);
  static const Color error = Color(0xFFC0392B);
  static const Color errorBg = Color(0xFFFDECEA);
  static const Color sidebarWidth = Color(0xFF240000);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          background: background,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          headlineLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineSmall: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primary),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: border),
          ),
          margin: EdgeInsets.zero,
        ),
        dividerColor: border,
      );
}