import 'package:intl/intl.dart';

/// Date and time formatting helpers.
abstract final class DateTimeUtils {
  static String formatDate(DateTime date, {String? pattern}) {
    return DateFormat(pattern ?? 'y-MM-dd').format(date);
  }

  static String formatDateTime(DateTime dateTime, {String? pattern}) {
    return DateFormat(pattern ?? 'y-MM-dd HH:mm').format(dateTime);
  }

  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    }

    if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    }

    if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    }

    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    }

    return 'Just now';
  }

  static DateTime? tryParse(String value) {
    try {
      return DateTime.parse(value);
    } on FormatException {
      return null;
    }
  }
}
