import 'package:personal_os_dashboard/core/utils/date_utils.dart';

export 'package:personal_os_dashboard/core/utils/date_utils.dart';

/// Backward-compatible alias. Prefer [DateUtils].
abstract final class DateTimeUtils {
  static String formatDate(DateTime date, {String? pattern}) =>
      DateUtils.formatDate(date, pattern: pattern);

  static String formatDateTime(DateTime dateTime, {String? pattern}) =>
      DateUtils.formatDateTime(dateTime, pattern: pattern);

  static String formatRelative(DateTime dateTime) =>
      DateUtils.formatRelative(dateTime);

  static DateTime? tryParse(String value) => DateUtils.tryParse(value);
}
