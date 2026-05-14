import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Gradient Colors
  static const Color primaryBlue = Color(0xFF4F8EF7);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color accentBlue = Color(0xFF60A5FA);

  // Status Colors
  static const Color safeGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color darkCard = Color(0xFF111827);
  static const Color darkCardAlt = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkSubtext = Color(0xFF9CA3AF);

  // Light Theme Colors
  static const Color lightBg = Color(0xFFF0F4FF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardAlt = Color(0xFFEFF6FF);
  static const Color lightBorder = Color(0xFFBFDBFE);
  static const Color lightText = Color(0xFF1E293B);
  static const Color lightSubtext = Color(0xFF64748B);

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [primaryBlue, primaryPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get cardGradient => const LinearGradient(
        colors: [Color(0xFF4F8EF7), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get safeGradient => const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get dangerGradient => const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryPurple,
        surface: darkCard,
        error: dangerRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: darkText, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: darkText, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: darkText),
          bodyMedium: TextStyle(color: darkSubtext),
          labelLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: darkSubtext),
        hintStyle: const TextStyle(color: darkSubtext),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: darkText),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: primaryBlue,
        unselectedItemColor: darkSubtext,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryPurple,
        surface: lightCard,
        error: dangerRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: lightText, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: lightText, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: lightText, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: lightText),
          bodyMedium: TextStyle(color: lightSubtext),
          labelLarge: TextStyle(color: lightText, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: lightSubtext),
        hintStyle: const TextStyle(color: lightSubtext),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: lightText),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCard,
        selectedItemColor: primaryBlue,
        unselectedItemColor: lightSubtext,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
