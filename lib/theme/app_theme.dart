import 'package:flutter/material.dart';

class AppTheme {
  static const accent = Color(0xFF2F806A);
  static const lime = Color(0xFFC7E7A4);
  static const ink = Color(0xFF182923);
  static const muted = Color(0xFF77847E);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      surface: dark ? const Color(0xFF17201C) : const Color(0xFFF7F8F5),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF101713) : const Color(0xFFF7F8F5),
      appBarTheme: AppBarTheme(
        backgroundColor:
            dark ? const Color(0xFF101713) : const Color(0xFFF7F8F5),
        foregroundColor: dark ? Colors.white : ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF1A2520) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: dark ? const Color(0xFFEAF0EC) : ink,
            displayColor: dark ? Colors.white : ink,
          ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF202C26) : const Color(0xFFF0F3EF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF17201C) : Colors.white,
        indicatorColor: dark
            ? accent.withValues(alpha: .24)
            : const Color(0xFFE3EFE9),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
