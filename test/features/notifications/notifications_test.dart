import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/features/calendar/data/datasources/local_calendar_data_source.dart';
import 'package:personal_os_dashboard/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:personal_os_dashboard/features/crm/data/datasources/local_crm_data_source.dart';
import 'package:personal_os_dashboard/features/crm/data/repositories/crm_repository_impl.dart';
import 'package:personal_os_dashboard/features/goals/data/datasources/local_goals_data_source.dart';
import 'package:personal_os_dashboard/features/goals/data/repositories/goals_repository_impl.dart';
import 'package:personal_os_dashboard/features/meetings/data/datasources/local_meetings_data_source.dart';
import 'package:personal_os_dashboard/features/meetings/data/repositories/meetings_repository_impl.dart';
import 'package:personal_os_dashboard/features/notifications/data/datasources/local_notifications_data_source.dart';
import 'package:personal_os_dashboard/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:personal_os_dashboard/features/notifications/data/services/reminder_scheduler_service.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/tasks/data/datasources/local_tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/data/repositories/tasks_repository_impl.dart';

void main() {
  late ReminderSchedulerService scheduler;
  late NotificationsRepositoryImpl notificationsRepository;

  setUp(() {
    notificationsRepository =
        NotificationsRepositoryImpl(LocalNotificationsDataSource());
    scheduler = ReminderSchedulerService(
      tasksRepository: TasksRepositoryImpl(LocalTasksDataSource()),
      meetingsRepository: MeetingsRepositoryImpl(LocalMeetingsDataSource()),
      goalsRepository: GoalsRepositoryImpl(LocalGoalsDataSource()),
      crmRepository: CrmRepositoryImpl(LocalCrmDataSource()),
      calendarRepository: CalendarRepositoryImpl(
        LocalCalendarDataSource(),
        tasksDataSource: LocalTasksDataSource(),
      ),
      notificationsRepository: notificationsRepository,
    );
  });

  group('ReminderSchedulerService', () {
    test('creates meeting reminder notifications from seeded data', () async {
      final created = await scheduler.syncReminders(userId: 'local-user');

      expect(
        created.any((n) => n.type == NotificationType.meetingReminder),
        isTrue,
      );
    });

    test('creates birthday reminder for contact with birthday today', () async {
      final created = await scheduler.syncReminders(userId: 'local-user');

      expect(
        created.any((n) => n.type == NotificationType.birthdayReminder),
        isTrue,
      );
    });

    test('does not duplicate notifications on repeated sync', () async {
      await scheduler.syncReminders(userId: 'local-user');
      final secondPass = await scheduler.syncReminders(userId: 'local-user');

      expect(secondPass, isEmpty);
    });
  });

  group('NotificationsRepository', () {
    test('tracks unread count', () async {
      final countBefore =
          await notificationsRepository.getUnreadCount(userId: 'local-user');
      expect(countBefore, greaterThan(0));

      final notifications =
          await notificationsRepository.getNotifications(userId: 'local-user');
      final unread = notifications.firstWhere((n) => !n.isRead);
      await notificationsRepository.markAsRead(id: unread.id);

      final countAfter =
          await notificationsRepository.getUnreadCount(userId: 'local-user');
      expect(countAfter, countBefore - 1);
    });
  });
}
