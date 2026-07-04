import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/features/calendar/data/datasources/local_calendar_data_source.dart';
import 'package:personal_os_dashboard/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';
import 'package:personal_os_dashboard/features/calendar/domain/usecases/calendar_usecases.dart';
import 'package:personal_os_dashboard/features/tasks/data/datasources/local_tasks_data_source.dart';

void main() {
  late CalendarRepositoryImpl repository;

  setUp(() {
    repository = CalendarRepositoryImpl(
      LocalCalendarDataSource(),
      tasksDataSource: LocalTasksDataSource(),
    );
  });

  group('Calendar use cases', () {
    test('loads seeded events for local user', () async {
      final now = DateTime.now();
      final result = await GetCalendarEventsUseCase(repository).call(
        (
          userId: 'local-user',
          rangeStart: app_date.DateUtils.startOfMonth(now),
          rangeEnd: app_date.DateUtils.endOfMonth(now),
        ),
      );

      expect(result.isSuccess, isTrue);
      result.when(
        success: (events) => expect(events.length, greaterThanOrEqualTo(5)),
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('includes task due dates from tasks module', () async {
      final now = DateTime.now();
      final result = await GetCalendarEventsUseCase(repository).call(
        (
          userId: 'local-user',
          rangeStart: now.subtract(const Duration(days: 30)),
          rangeEnd: now.add(const Duration(days: 30)),
        ),
      );

      result.when(
        success: (events) {
          expect(
            events.any((e) => e.eventType == CalendarEventType.task),
            isTrue,
          );
        },
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('creates, updates, and deletes an event', () async {
      const userId = 'test-user';
      final start = DateTime.now().add(const Duration(days: 1, hours: 10));
      final end = start.add(const Duration(hours: 1));

      final createResult = await CreateCalendarEventUseCase(repository).call(
        CreateCalendarEventRequest(
          userId: userId,
          event: CreateCalendarEventParams(
            title: 'Team standup',
            description: 'Daily sync',
            eventType: CalendarEventType.meeting.storageValue,
            startTime: start,
            endTime: end,
            isAllDay: false,
            location: 'Zoom',
            reminderAt: start.subtract(const Duration(minutes: 15)),
            attendeeCount: 5,
            linkedTaskId: null,
          ),
        ),
      );

      late String eventId;
      createResult.when(
        success: (event) {
          eventId = event.id;
          expect(event.title, 'Team standup');
          expect(event.eventType, CalendarEventType.meeting);
        },
        onFailure: (_) => fail('Create failed'),
      );

      final updateResult = await UpdateCalendarEventUseCase(repository).call(
        UpdateCalendarEventRequest(
          userId: userId,
          event: UpdateCalendarEventParams(
            id: eventId,
            title: 'Updated standup',
            description: 'Updated agenda',
            eventType: CalendarEventType.meeting.storageValue,
            startTime: start,
            endTime: end.add(const Duration(minutes: 30)),
            isAllDay: false,
            location: 'Office',
            reminderAt: null,
            attendeeCount: 8,
            linkedTaskId: null,
            clearReminder: true,
          ),
        ),
      );

      updateResult.when(
        success: (event) {
          expect(event.title, 'Updated standup');
          expect(event.attendeeCount, 8);
          expect(event.reminderAt, isNull);
        },
        onFailure: (_) => fail('Update failed'),
      );

      final deleteResult =
          await DeleteCalendarEventUseCase(repository).call(eventId);
      expect(deleteResult.isSuccess, isTrue);

      final getResult =
          await GetCalendarEventByIdUseCase(repository).call(eventId);
      expect(getResult.isFailure, isTrue);
    });
  });
}
