/// Global application constants.
abstract final class AppConstants {
  static const String appName = 'Personal OS';
  static const String appVersion = '1.0.0';

  static const Duration defaultAnimationDuration = Duration(milliseconds: 250);
  static const Duration debounceDuration = Duration(milliseconds: 400);
  static const Duration snackBarDuration = Duration(seconds: 4);

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  static const double maxContentWidth = 1200;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
}
