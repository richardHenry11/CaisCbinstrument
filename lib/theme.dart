import 'package:flutter/material.dart';

class AppTheme {
  // Shared accent colors
  static const Color cyanAccent = Color(0xFF22d3ee);
  static const Color brandBlue = Color(0xFF2AACEB);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0a0f1e),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0f1729),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardColor: const Color(0xFF0f1729),
      dividerColor: Colors.white12,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF22d3ee),
        secondary: Color(0xFF0ea5e9),
        surface: Color(0xFF0f1729),
        onSurface: Colors.white,
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFf1f5f9),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFffffff),
        foregroundColor: Color(0xFF0f1729),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0f1729)),
      ),
      cardColor: Colors.white,
      dividerColor: Colors.black12,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0284c7),
        secondary: Color(0xFF0369a1),
        surface: Colors.white,
        onSurface: Color(0xFF0f1729),
      ),
    );
  }

  static Color cardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0f1729) : const Color(0xFFffffff);
  }

  static Color cardGradientStart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF1e293b).withValues(alpha: 0.9)
        : const Color(0xFFf8fafc);
  }

  static Color cardGradientEnd(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF0f1729).withValues(alpha: 0.95)
        : const Color(0xFFf1f5f9);
  }

  static Color borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.08);
  }

  static Color textPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.95)
        : const Color(0xFF0f1729).withValues(alpha: 0.95);
  }

  static Color textSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF475569).withValues(alpha: 0.8);
  }

  static Color surfaceLow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color(0xFF0f1729).withValues(alpha: 0.5)
        : const Color(0xFFe2e8f0).withValues(alpha: 0.7);
  }
}
