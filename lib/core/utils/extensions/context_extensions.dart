import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  bool get isTablet => screenSize.width >= AppConstants.tabletBreakpoint;

  bool get isDesktop => screenSize.width >= AppConstants.desktopBreakpoint;

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void showAppSnackBar(
    String message, {
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        action: action,
        duration: AppConstants.snackBarDuration,
      ),
    );
  }
}
