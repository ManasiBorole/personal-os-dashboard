import 'package:personal_os_dashboard/core/domain/entities/entity.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';

/// Calendar event types displayed in the schedule.
enum CalendarEventType {
  task('Task'),
  meeting('Meeting'),
  birthday('Birthday'),
  reminder('Reminder');

  const CalendarEventType(this.label);

  final String label;

  static CalendarEventType fromString(String? value) {
    final normalized = value?.toLowerCase().replaceAll(' ', '_');
    return CalendarEventType.values.firstWhere(
      (t) => t.name == normalized || t.storageValue == normalized,
      orElse: () => CalendarEventType.meeting,
    );
  }

  String get storageValue => name;
}

/// View mode for the calendar screen.
enum CalendarViewMode {
  day('Day'),
  week('Week'),
  month('Month');

  const CalendarViewMode(this.label);

  final String label;
}

/// Domain calendar event entity.
final class CalendarEvent extends Entity {
  const CalendarEvent({
    required this.id,
    required this.userId,
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
    required this.isReadOnly,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final CalendarEventType eventType;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String? location;
  final DateTime? reminderAt;
  final int attendeeCount;
  final String? linkedTaskId;
  final bool isReadOnly;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get durationMinutes =>
      endTime.difference(startTime).inMinutes.clamp(1, 24 * 60);

  bool occursOnDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return startTime.isBefore(end) && endTime.isAfter(start);
  }

  CalendarEvent copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    CalendarEventType? eventType,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? location,
    DateTime? reminderAt,
    int? attendeeCount,
    String? linkedTaskId,
    bool? isReadOnly,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearLocation = false,
    bool clearReminder = false,
    bool clearLinkedTaskId = false,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      location: clearLocation ? null : (location ?? this.location),
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      attendeeCount: attendeeCount ?? this.attendeeCount,
      linkedTaskId:
          clearLinkedTaskId ? null : (linkedTaskId ?? this.linkedTaskId),
      isReadOnly: isReadOnly ?? this.isReadOnly,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  CalendarPreviewItem toPreviewItem() {
    return CalendarPreviewItem(
      id: id,
      title: title,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      category: eventType.label,
    );
  }

  UpcomingMeetingItem? toMeetingItem() {
    if (eventType != CalendarEventType.meeting) return null;
    return UpcomingMeetingItem(
      id: id,
      title: title,
      startTime: startTime,
      durationMinutes: durationMinutes,
      location: location,
      attendeeCount: attendeeCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        eventType,
        startTime,
        endTime,
        isAllDay,
        location,
        reminderAt,
        attendeeCount,
        linkedTaskId,
        isReadOnly,
        createdAt,
        updatedAt,
      ];
}
