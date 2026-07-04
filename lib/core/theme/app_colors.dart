import 'package:flutter/material.dart';

/// Application color palette for light and dark themes.
abstract final class AppColors {
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryDark = Color(0xFF1446B0);
  static const Color secondary = Color(0xFF0E9F6E);
  static const Color accent = Color(0xFFF59E0B);

  static const Color success = Color(0xFF057A55);
  static const Color warning = Color(0xFFC27803);
  static const Color error = Color(0xFFE02424);
  static const Color info = Color(0xFF1C64F2);

  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
}
