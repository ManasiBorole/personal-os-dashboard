import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/config/environment.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/core/error/failures.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart';
import 'package:personal_os_dashboard/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email rejects invalid addresses', () {
      expect(Validators.email('invalid'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);
    });

    test('strongPassword enforces complexity', () {
      expect(Validators.strongPassword('password'), isNotNull);
      expect(Validators.strongPassword('Password1!'), isNull);
    });

    test('combine returns first validation error', () {
      final validator = Validators.combine([
        Validators.required,
        (value) => Validators.minLength(value, 5),
      ]);

      expect(validator(''), isNotNull);
      expect(validator('abc'), isNotNull);
      expect(validator('abcdef'), isNull);
    });
  });

  group('DateUtils', () {
    test('isToday returns true for current date', () {
      expect(DateUtils.isToday(DateTime.now()), isTrue);
    });

    test('startOfDay normalizes time component', () {
      final date = DateTime(2026, 7, 4, 15, 30);
      final start = DateUtils.startOfDay(date);

      expect(start.hour, 0);
      expect(start.minute, 0);
    });

    test('formatRelative returns human-readable value', () {
      final result = DateUtils.formatRelative(
        DateTime.now().subtract(const Duration(minutes: 2)),
      );

      expect(result, '2m ago');
    });
  });

  group('ErrorHandler', () {
    late ErrorHandler errorHandler;

    setUp(() {
      const config = AppConfig(
        environment: AppEnvironment.dev,
        supabaseUrl: '',
        supabaseAnonKey: '',
        developmentMode: false,
      );
      errorHandler = ErrorHandler(AppLogger(config));
    });

    test('maps failures to user-friendly messages', () {
      const failure = NetworkFailure('offline');
      final message = errorHandler.getUserMessage(failure);

      expect(message, contains('internet connection'));
    });
  });
}
