import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';

/// Parameters for creating a calendar event.
final class CreateCalendarEventParams {
  const CreateCalendarEventParams({
    required this.title,
    required this.description,
    required this.eventType,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    required this.location,
    required this.reminderAt,
    required this.attendeeCount,
    required this.linkedTaskId,
  });

  final String title;
  final String description;
  final String eventType;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? location;
  final DateTime? reminderAt;
  final int attendeeCount;
  final String? linkedTaskId;
}

/// Parameters for updating a calendar event.
final class UpdateCalendarEventParams {
  const UpdateCalendarEventParams({
    required this.id,
    required this.title,
    required this.description,
    required this.eventType,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    required this.location,
    required this.reminderAt,
    required this.attendeeCount,
    required this.linkedTaskId,
    this.clearLocation = false,
    this.clearReminder = false,
    this.clearLinkedTaskId = false,
  });

  final String id;
  final String title;
  final String description;
  final String eventType;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? location;
  final DateTime? reminderAt;
  final int attendeeCount;
  final String? linkedTaskId;
  final bool clearLocation;
  final bool clearReminder;
  final bool clearLinkedTaskId;
}

/// Filter for calendar events.
final class CalendarEventFilter {
  const CalendarEventFilter({
    this.types,
    this.searchQuery,
  });

  final Set<CalendarEventType>? types;
  final String? searchQuery;

  static const CalendarEventFilter empty = CalendarEventFilter();

  CalendarEventFilter copyWith({
    Set<CalendarEventType>? types,
    String? searchQuery,
    bool clearTypes = false,
    bool clearSearch = false,
  }) {
    return CalendarEventFilter(
      types: clearTypes ? null : (types ?? this.types),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }

  bool get hasActiveFilters =>
      (types != null && types!.isNotEmpty) ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}
