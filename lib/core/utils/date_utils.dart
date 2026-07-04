import 'package:intl/intl.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';

/// Enterprise date and time utility helpers.
abstract final class DateUtils {
  static final DateFormat _isoDateFormatter = DateFormat(AppConstants.dateFormat);
  static final DateFormat _isoDateTimeFormatter =
      DateFormat(AppConstants.dateTimeFormat);
  static final DateFormat _displayDateFormatter =
      DateFormat(AppConstants.displayDateFormat);
  static final DateFormat _displayDateTimeFormatter =
      DateFormat(AppConstants.displayDateTimeFormat);
  static final DateFormat _timeFormatter = DateFormat(AppConstants.timeFormat);

  // Formatting

  static String formatDate(DateTime date, {String? pattern}) {
    if (pattern != null) {
      return DateFormat(pattern).format(date);
    }
    return _isoDateFormatter.format(date);
  }

  static String formatDateTime(DateTime dateTime, {String? pattern}) {
    if (pattern != null) {
      return DateFormat(pattern).format(dateTime);
    }
    return _isoDateTimeFormatter.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeFormatter.format(dateTime);
  }

  static String formatDisplayDate(DateTime date) {
    return _displayDateFormatter.format(date);
  }

  static String formatDisplayDateTime(DateTime dateTime) {
    return _displayDateTimeFormatter.format(dateTime);
  }

  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return 'In the future';
    }

    if (difference.inDays > 7) {
      return formatDisplayDate(dateTime);
    }

    if (difference.inDays >= 1) {
      return difference.inDays == 1 ? 'Yesterday' : '${difference.inDays} days ago';
    }

    if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    }

    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    }

    return 'Just now';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    if (minutes > 0) {
      return '${minutes}m';
    }

    return '${duration.inSeconds}s';
  }

  // Parsing

  static DateTime? tryParse(String value) {
    try {
      return DateTime.parse(value);
    } on FormatException {
      return null;
    }
  }

  static DateTime? tryParseWithPattern(String value, String pattern) {
    try {
      return DateFormat(pattern).parseStrict(value);
    } on FormatException {
      return null;
    }
  }

  // Comparisons

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static bool isInPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static bool isInFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // Boundaries

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return endOfDay(date.add(Duration(days: DateTime.daysPerWeek - weekday)));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Conversion

  static DateTime toLocal(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  static DateTime toUtc(DateTime localDateTime) {
    return localDateTime.toUtc();
  }

  static String toIsoString(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }
}
