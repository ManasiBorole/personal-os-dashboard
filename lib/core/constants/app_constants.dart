/// Global application constants used across all modules.
abstract final class AppConstants {
  // Application identity
  static const String appName = 'Personal OS';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.personalos.personal_os_dashboard';

  // Animation & timing
  static const Duration defaultAnimationDuration = Duration(milliseconds: 250);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 400);
  static const Duration debounceDuration = Duration(milliseconds: 400);
  static const Duration throttleDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration splashMinDuration = Duration(milliseconds: 1500);

  // Network
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int initialPage = 1;

  // Layout & breakpoints
  static const double maxContentWidth = 1200;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double mobileBreakpoint = 480;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxTitleLength = 255;
  static const int maxDescriptionLength = 5000;
  static const int maxNoteLength = 50000;

  // Storage
  static const String hiveBoxName = 'personal_os_cache';
  static const String secureStoragePrefix = 'personal_os_secure_';

  // Date formats
  static const String dateFormat = 'y-MM-dd';
  static const String dateTimeFormat = 'y-MM-dd HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String displayDateFormat = 'MMM d, y';
  static const String displayDateTimeFormat = 'MMM d, y • h:mm a';

  // Locale
  static const String defaultLocale = 'en_US';
  static const String defaultCurrency = 'USD';
}
