import 'package:logger/logger.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';

/// Enterprise application logger with environment-aware log levels.
final class AppLogger {
  AppLogger(AppConfig config) : _logger = _createLogger(config);

  final Logger _logger;

  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  static Logger _createLogger(AppConfig config) {
    return Logger(
      printer: PrettyPrinter(
        methodCount: config.environment.isProd ? 0 : 2,
        errorMethodCount: config.environment.isProd ? 3 : 8,
        lineLength: 120,
        colors: !config.environment.isProd,
        printEmojis: !config.environment.isProd,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: config.environment.isProd ? Level.warning : Level.debug,
    );
  }
}
