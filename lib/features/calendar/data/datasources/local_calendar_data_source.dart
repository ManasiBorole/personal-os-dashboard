import 'package:personal_os_dashboard/features/calendar/data/datasources/calendar_data_source.dart';
import 'package:personal_os_dashboard/features/calendar/data/models/calendar_event_model.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';

final class LocalCalendarDataSource implements CalendarDataSource {
  final Map<String, CalendarEventModel> _events = {};

  LocalCalendarDataSource() {
    _seed();
  }

  void _seed() {
    const userId = 'local-user';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final events = [
      CalendarEventModel(
        id: 'cal-local-1',
        userId: userId,
        title: 'Sprint planning',
        description: 'Plan sprint goals and assign tasks.',
        eventType: CalendarEventType.meeting.storageValue,
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 11, minutes: 30)),
        isAllDay: false,
        location: 'Conference Room A',
        reminderAt: today.add(const Duration(hours: 9, minutes: 30)),
        attendeeCount: 8,
        linkedTaskId: null,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      CalendarEventModel(
        id: 'cal-local-2',
        userId: userId,
        title: 'Gym session',
        description: 'Morning workout routine.',
        eventType: CalendarEventType.reminder.storageValue,
        startTime: today.add(const Duration(hours: 7)),
        endTime: today.add(const Duration(hours: 8)),
        isAllDay: false,
        location: 'Fitness Center',
        reminderAt: today.add(const Duration(hours: 6, minutes: 45)),
        attendeeCount: 0,
        linkedTaskId: null,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      CalendarEventModel(
        id: 'cal-local-3',
        userId: userId,
        title: 'Team offsite',
        description: 'Quarterly team building event.',
        eventType: CalendarEventType.meeting.storageValue,
        startTime: today.add(const Duration(days: 2)),
        endTime: today.add(const Duration(days: 2, hours: 8)),
        isAllDay: true,
        location: 'Mountain Lodge',
        reminderAt: null,
        attendeeCount: 15,
        linkedTaskId: null,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      CalendarEventModel(
        id: 'cal-local-4',
        userId: userId,
        title: 'Dentist appointment',
        description: 'Routine checkup.',
        eventType: CalendarEventType.reminder.storageValue,
        startTime: today.add(const Duration(days: 3, hours: 15)),
        endTime: today.add(const Duration(days: 3, hours: 16)),
        isAllDay: false,
        location: 'Downtown Dental',
        reminderAt: today.add(const Duration(days: 3, hours: 14)),
        attendeeCount: 0,
        linkedTaskId: null,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      CalendarEventModel(
        id: 'cal-local-5',
        userId: userId,
        title: 'Mom\'s birthday',
        description: 'Send flowers and call.',
        eventType: CalendarEventType.birthday.storageValue,
        startTime: today.add(const Duration(days: 5)),
        endTime: today.add(const Duration(days: 5, hours: 23, minutes: 59)),
        isAllDay: true,
        location: null,
        reminderAt: today.add(const Duration(days: 4, hours: 9)),
        attendeeCount: 0,
        linkedTaskId: null,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      CalendarEventModel(
        id: 'cal-local-6',
        userId: userId,
        title: 'Build task management module',
        description: 'Linked task deadline.',
        eventType: CalendarEventType.task.storageValue,
        startTime: today.add(const Duration(days: 7, hours: 9)),
        endTime: today.add(const Duration(days: 7, hours: 17)),
        isAllDay: false,
        location: null,
        reminderAt: today.add(const Duration(days: 6, hours: 18)),
        attendeeCount: 0,
        linkedTaskId: 'task-local-2',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      CalendarEventModel(
        id: 'cal-local-7',
        userId: userId,
        title: 'Product sync',
        description: 'Weekly product alignment meeting.',
        eventType: CalendarEventType.meeting.storageValue,
        startTime: today.add(const Duration(hours: 14)),
        endTime: today.add(const Duration(hours: 14, minutes: 45)),
        isAllDay: false,
        location: 'Zoom',
        reminderAt: today.add(const Duration(hours: 13, minutes: 45)),
        attendeeCount: 6,
        linkedTaskId: null,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
    ];

    for (final event in events) {
      _events[event.id] = event;
    }
  }

  bool _inRange(CalendarEventModel event, DateTime start, DateTime end) {
    return event.startTime.isBefore(end) && event.endTime.isAfter(start);
  }

  @override
  Future<List<CalendarEventModel>> getEvents({
    required String userId,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    return _events.values
        .where(
          (e) =>
              (e.userId == userId || e.userId == 'local-user') &&
              _inRange(e, rangeStart, rangeEnd),
        )
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<CalendarEventModel> getEventById({required String id}) async {
    final event = _events[id];
    if (event == null) throw StateError('Calendar event not found');
    return event;
  }

  @override
  Future<CalendarEventModel> createEvent({
    required String userId,
    required CreateCalendarEventParams params,
  }) async {
    final now = DateTime.now();
    final id = 'cal-local-${now.microsecondsSinceEpoch}';
    final event = CalendarEventModel(
      id: id,
      userId: userId,
      title: params.title.trim(),
      description: params.description.trim(),
      eventType: params.eventType,
      startTime: params.startTime,
      endTime: params.endTime,
      isAllDay: params.isAllDay,
      location: params.location,
      reminderAt: params.reminderAt,
      attendeeCount: params.attendeeCount,
      linkedTaskId: params.linkedTaskId,
      createdAt: now,
      updatedAt: now,
    );
    _events[id] = event;
    return event;
  }

  @override
  Future<CalendarEventModel> updateEvent({
    required String userId,
    required UpdateCalendarEventParams params,
  }) async {
    final existing = await getEventById(id: params.id);
    final updated = CalendarEventModel(
      id: existing.id,
      userId: userId,
      title: params.title.trim(),
      description: params.description.trim(),
      eventType: params.eventType,
      startTime: params.startTime,
      endTime: params.endTime,
      isAllDay: params.isAllDay,
      location: params.clearLocation ? null : params.location,
      reminderAt: params.clearReminder ? null : params.reminderAt,
      attendeeCount: params.attendeeCount,
      linkedTaskId:
          params.clearLinkedTaskId ? null : params.linkedTaskId,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _events[updated.id] = updated;
    return updated;
  }

  @override
  Future<void> deleteEvent({required String id}) async {
    _events.remove(id);
  }
}
