import 'package:flutter/material.dart';

class GlassTheme {
  // Dark Glassmorphism Emerald Color Palette
  static const Color background = Color(0xFF06140E);
  static const Color backgroundSecondary = Color(0xFF0B2117);

  // Neon & Emerald Accents
  static const Color primaryNeon = Color(0xFF00FF87);
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF2A85FF);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  // Glass Card Colors
  static const Color glassFill = Color(0xCC0D2B1E);
  static const Color glassFillLight = Color(0x99143D2C);
  static const Color glassBorder = Color(0x3300FF87);
  static const Color glassBorderLight = Color(0x22FFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryNeon,
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: primaryEmerald,
        surface: glassFill,
        error: errorRed,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
