import 'package:flutter/material.dart';

class MaliTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      primaryColor: const Color(0xFF1976D2),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      fontFamily: 'IBMPlexSansArabic',
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1976D2),
        secondary: Color(0xFF03A9F4),
        surface: Colors.white,
        error: Color(0xFFD32F2F),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
