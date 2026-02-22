import 'package:flutter/material.dart';

class AppThemes {
  static const terracotta = Color(0xFFE07C24);
  static const turquoise = Color(0xFF2A9D8F);
  static const gold = Color(0xFFD4A574);
  static const sand = Color(0xFFE8DCC8);
  static const cream = Color(0xFFFAF7F2);

  /// السمة المصرية - وضع فاتح
  static ThemeData get egyptianLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: cream,
      colorScheme: const ColorScheme.light(
        primary: terracotta,
        secondary: turquoise,
        tertiary: gold,
        surface: cream,
        onSurface: Color(0xFF2D2D2D),
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: Color(0xFF2D2D2D),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sand.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: turquoise, width: 2),
        ),
      ),
    );
  }

  /// السمة المصرية - وضع داكن
  static ThemeData get egyptianDark {
    const darkBg = Color(0xFF1A1A1A);
    const darkSurface = Color(0xFF252525);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: terracotta,
        secondary: turquoise,
        tertiary: gold,
        surface: darkSurface,
        onSurface: Colors.white,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: turquoise, width: 2),
        ),
      ),
    );
  }

  static ThemeData themeFromDarkMode(bool isDark) {
    return isDark ? egyptianDark : egyptianLight;
  }
}
