import 'package:personal_os_dashboard/features/calendar/data/datasources/calendar_data_source.dart';
import 'package:personal_os_dashboard/features/calendar/data/datasources/local_calendar_data_source.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';
import 'package:personal_os_dashboard/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:personal_os_dashboard/features/tasks/data/datasources/local_tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/data/datasources/tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';

final class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._dataSource, {TasksDataSource? tasksDataSource})
      : _tasksDataSource = tasksDataSource;

  final CalendarDataSource _dataSource;
  final TasksDataSource? _tasksDataSource;

  @override
  Future<List<CalendarEvent>> getEvents({
    required String userId,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final models = await _dataSource.getEvents(
      userId: userId,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );

    final events = models.map((m) => m.toEntity()).toList();
    final taskEvents = await _taskEventsForRange(
      userId: userId,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      existingLinkedIds: models
          .map((m) => m.linkedTaskId)
          .whereType<String>()
          .toSet(),
    );

    return [...events, ...taskEvents]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<List<CalendarEvent>> _taskEventsForRange({
    required String userId,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required Set<String> existingLinkedIds,
  }) async {
    final tasksSource = _tasksDataSource;
    if (tasksSource == null) return const [];

    final taskModels = await tasksSource.getTasks(userId: userId);
    final events = <CalendarEvent>[];

    for (final model in taskModels) {
      final task = model.toEntity();

      if (task.dueDate != null &&
          !existingLinkedIds.contains(task.id) &&
          _overlaps(task.dueDate!, rangeStart, rangeEnd)) {
        events.add(_taskToEvent(task, useReminder: false));
      }

      if (task.reminderAt != null &&
          _overlaps(task.reminderAt!, rangeStart, rangeEnd)) {
        events.add(_taskToEvent(task, useReminder: true));
      }
    }

    return events;
  }

  bool _overlaps(DateTime point, DateTime start, DateTime end) {
    final eventEnd = point.add(const Duration(hours: 1));
    return point.isBefore(end) && eventEnd.isAfter(start);
  }

  CalendarEvent _taskToEvent(Task task, {required bool useReminder}) {
    final start = useReminder ? task.reminderAt! : task.dueDate!;
    final end = useReminder
        ? start.add(const Duration(minutes: 30))
        : start.add(const Duration(hours: 1));

    return CalendarEvent(
      id: useReminder ? 'task-reminder-${task.id}' : 'task-due-${task.id}',
      userId: task.userId,
      title: useReminder ? 'Reminder: ${task.title}' : task.title,
      description: task.description,
      eventType:
          useReminder ? CalendarEventType.reminder : CalendarEventType.task,
      startTime: start,
      endTime: end,
      isAllDay: !useReminder && task.dueDate != null,
      location: null,
      reminderAt: task.reminderAt,
      attendeeCount: 0,
      linkedTaskId: task.id,
      isReadOnly: true,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  @override
  Future<CalendarEvent> getEventById({required String id}) async {
    if (id.startsWith('task-due-') || id.startsWith('task-reminder-')) {
      throw StateError('Read-only task events cannot be loaded individually');
    }
    final model = await _dataSource.getEventById(id: id);
    return model.toEntity();
  }

  @override
  Future<CalendarEvent> createEvent({
    required String userId,
    required CreateCalendarEventParams params,
  }) async {
    final model = await _dataSource.createEvent(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<CalendarEvent> updateEvent({
    required String userId,
    required UpdateCalendarEventParams params,
  }) async {
    final model = await _dataSource.updateEvent(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteEvent({required String id}) async {
    if (id.startsWith('task-due-') || id.startsWith('task-reminder-')) {
      throw StateError('Read-only task events cannot be deleted from calendar');
    }
    await _dataSource.deleteEvent(id: id);
  }
}

final class UnconfiguredCalendarRepository implements CalendarRepository {
  UnconfiguredCalendarRepository()
      : _delegate = CalendarRepositoryImpl(
          LocalCalendarDataSource(),
          tasksDataSource: LocalTasksDataSource(),
        );

  final CalendarRepositoryImpl _delegate;

  @override
  Future<List<CalendarEvent>> getEvents({
    required String userId,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) =>
      _delegate.getEvents(
        userId: userId,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
      );

  @override
  Future<CalendarEvent> getEventById({required String id}) =>
      _delegate.getEventById(id: id);

  @override
  Future<CalendarEvent> createEvent({
    required String userId,
    required CreateCalendarEventParams params,
  }) =>
      _delegate.createEvent(userId: userId, params: params);

  @override
  Future<CalendarEvent> updateEvent({
    required String userId,
    required UpdateCalendarEventParams params,
  }) =>
      _delegate.updateEvent(userId: userId, params: params);

  @override
  Future<void> deleteEvent({required String id}) =>
      _delegate.deleteEvent(id: id);
}

CalendarRepository createCalendarRepository({
  required bool isSupabaseReady,
  required CalendarDataSource remoteDataSource,
  TasksDataSource? tasksDataSource,
}) {
  if (isSupabaseReady) {
    return CalendarRepositoryImpl(
      remoteDataSource,
      tasksDataSource: tasksDataSource,
    );
  }
  return UnconfiguredCalendarRepository();
}
