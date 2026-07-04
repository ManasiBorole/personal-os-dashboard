import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';

final class CalendarEventModel {
  const CalendarEventModel({
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
    required this.createdAt,
    required this.updatedAt,
    this.isReadOnly = false,
  });

  final String id;
  final String userId;
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isReadOnly;

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      eventType: json['event_type']?.toString() ?? 'meeting',
      startTime: _parseDate(json['start_time']) ?? DateTime.now(),
      endTime: _parseDate(json['end_time']) ??
          DateTime.now().add(const Duration(hours: 1)),
      isAllDay: json['is_all_day'] as bool? ?? false,
      location: json['location']?.toString(),
      reminderAt: _parseDate(json['reminder_at']),
      attendeeCount: json['attendee_count'] as int? ?? 0,
      linkedTaskId: json['linked_task_id']?.toString(),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    final now = DateTime.now().toIso8601String();
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'event_type': eventType,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_all_day': isAllDay,
      'location': location,
      'reminder_at': reminderAt?.toIso8601String(),
      'attendee_count': attendeeCount,
      'linked_task_id': linkedTaskId,
      'created_at': now,
      'updated_at': now,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'event_type': eventType,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_all_day': isAllDay,
      'location': location,
      'reminder_at': reminderAt?.toIso8601String(),
      'attendee_count': attendeeCount,
      'linked_task_id': linkedTaskId,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  CalendarEvent toEntity() {
    return CalendarEvent(
      id: id,
      userId: userId,
      title: title,
      description: description,
      eventType: CalendarEventType.fromString(eventType),
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      location: location,
      reminderAt: reminderAt,
      attendeeCount: attendeeCount,
      linkedTaskId: linkedTaskId,
      isReadOnly: isReadOnly,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
