import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgPrimary = Color(0xFF0F172A);
  static const Color bgSecondary = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color accentHover = Color(0xFF2563EB);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color glassBg = Color(0xB31E293B); // rgba(30, 41, 59, 0.7)
  static const Color glassBorder = Color(
    0x14FFFFFF,
  ); // rgba(255, 255, 255, 0.08)

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: bgSecondary,
        surface: bgSecondary,
        error: danger,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textPrimary),
          titleLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  static BoxDecoration glassDecoration = BoxDecoration(
    color: glassBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: glassBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 6,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
