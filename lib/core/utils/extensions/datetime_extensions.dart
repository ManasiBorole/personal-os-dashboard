import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toDisplayDate() => DateFormat.yMMMd().format(this);

  String toDisplayDateTime() => DateFormat.yMMMd().add_jm().format(this);

  String toDisplayTime() => DateFormat.jm().format(this);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}
