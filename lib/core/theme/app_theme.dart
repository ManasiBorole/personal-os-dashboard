import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/dark_theme.dart';
import 'package:personal_os_dashboard/core/theme/light_theme.dart';

/// Application theme entry point.
abstract final class AppTheme {
  static ThemeData get light => LightTheme.data;

  static ThemeData get dark => DarkTheme.data;
}
