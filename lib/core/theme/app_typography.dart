import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';

/// Enterprise typography system aligned with Material 3 type scale.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';
  static const String monoFontFamily = 'monospace';

  /// Full text theme for the given brightness.
  static TextTheme textTheme(Brightness brightness) {
    final primary = AppColors.textPrimary(brightness);
    final secondary = AppColors.textSecondary(brightness);
    final tertiary = brightness == Brightness.light
        ? AppColors.lightTextTertiary
        : AppColors.darkTextTertiary;

    return TextTheme(
      displayLarge: displayLarge(primary),
      displayMedium: displayMedium(primary),
      displaySmall: displaySmall(primary),
      headlineLarge: headlineLarge(primary),
      headlineMedium: headlineMedium(primary),
      headlineSmall: headlineSmall(primary),
      titleLarge: titleLarge(primary),
      titleMedium: titleMedium(primary),
      titleSmall: titleSmall(primary),
      bodyLarge: bodyLarge(primary),
      bodyMedium: bodyMedium(primary),
      bodySmall: bodySmall(secondary),
      labelLarge: labelLarge(primary),
      labelMedium: labelMedium(secondary),
      labelSmall: labelSmall(tertiary),
    );
  }

  static TextStyle displayLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.25,
        color: color,
      );

  static TextStyle displayMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w700,
        height: 1.16,
        color: color,
      );

  static TextStyle displaySmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.22,
        color: color,
      );

  static TextStyle headlineLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color,
      );

  static TextStyle headlineMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
        color: color,
      );

  static TextStyle headlineSmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: color,
      );

  static TextStyle titleLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
        color: color,
      );

  static TextStyle titleMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0.15,
        color: color,
      );

  static TextStyle titleSmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle bodyLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle bodyMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
        color: color,
      );

  static TextStyle bodySmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
        color: color,
      );

  static TextStyle labelLarge(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelMedium(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle labelSmall(Color color) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle mono(Color color, {double fontSize = 14}) => TextStyle(
        fontFamily: monoFontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );
}
