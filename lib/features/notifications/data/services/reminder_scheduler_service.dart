import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:personal_os_dashboard/features/crm/domain/entities/contact.dart';
import 'package:personal_os_dashboard/features/crm/domain/repositories/crm_repository.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/goals/domain/repositories/goals_repository.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification_params.dart';
import 'package:personal_os_dashboard/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/repositories/tasks_repository.dart';

/// Scans tasks, meetings, goals, and birthdays to create reminder notifications.
final class ReminderSchedulerService {
  ReminderSchedulerService({
    required TasksRepository tasksRepository,
    required MeetingsRepository meetingsRepository,
    required GoalsRepository goalsRepository,
    required CrmRepository crmRepository,
    required CalendarRepository calendarRepository,
    required NotificationsRepository notificationsRepository,
  })  : _tasksRepository = tasksRepository,
        _meetingsRepository = meetingsRepository,
        _goalsRepository = goalsRepository,
        _crmRepository = crmRepository,
        _calendarRepository = calendarRepository,
        _notificationsRepository = notificationsRepository;

  final TasksRepository _tasksRepository;
  final MeetingsRepository _meetingsRepository;
  final GoalsRepository _goalsRepository;
  final CrmRepository _crmRepository;
  final CalendarRepository _calendarRepository;
  final NotificationsRepository _notificationsRepository;

  static const _lookahead = Duration(hours: 24);
  static const _grace = Duration(minutes: 5);

  Future<List<AppNotification>> syncReminders({required String userId}) async {
    final now = DateTime.now();
    final windowEnd = now.add(_lookahead);
    final candidates = <CreateNotificationParams>[];

    final tasks = await _tasksRepository.getTasks(userId: userId);
    for (final task in tasks) {
      if (task.isSubtask) continue;
      final reminder = _taskReminder(task, now, windowEnd);
      if (reminder != null) candidates.add(reminder);
    }

    final meetings = await _meetingsRepository.getMeetings(userId: userId);
    for (final meeting in meetings) {
      final reminder = _meetingReminder(meeting, now, windowEnd);
      if (reminder != null) candidates.add(reminder);
    }

    final goals = await _goalsRepository.getGoals(userId: userId);
    for (final goal in goals) {
      final reminder = _goalDeadlineReminder(goal, now, windowEnd);
      if (reminder != null) candidates.add(reminder);
    }

    final contacts = await _crmRepository.getContacts(userId: userId);
    for (final contact in contacts) {
      final reminder = _contactBirthdayReminder(contact, now);
      if (reminder != null) candidates.add(reminder);
    }

    final rangeStart = DateTime(now.year, now.month, now.day);
    final rangeEnd = rangeStart.add(const Duration(days: 1));
    final events = await _calendarRepository.getEvents(
      userId: userId,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
    for (final event in events) {
      if (event.eventType != CalendarEventType.birthday) continue;
      final reminder = _calendarBirthdayReminder(event, now);
      if (reminder != null) candidates.add(reminder);
    }

    final created = <AppNotification>[];
    for (final params in candidates) {
      final exists = await _notificationsRepository.existsByDedupeKey(
        userId: userId,
        dedupeKey: params.dedupeKey,
      );
      if (exists) continue;

      final isDue = params.scheduledAt == null ||
          !params.scheduledAt!.isAfter(now.add(_grace));

      if (!isDue) continue;

      final notification = await _notificationsRepository.createNotification(
        userId: userId,
        params: params,
      );
      created.add(notification);
    }

    return created;
  }

  CreateNotificationParams? _taskReminder(
    Task task,
    DateTime now,
    DateTime windowEnd,
  ) {
    final reminderAt = task.reminderAt;
    if (reminderAt == null) return null;
    if (task.status == TaskStatus.completed ||
        task.status == TaskStatus.cancelled) {
      return null;
    }
    if (!_isInWindow(reminderAt, now, windowEnd)) return null;

    return CreateNotificationParams(
      type: NotificationType.taskReminder,
      title: 'Task reminder: ${task.title}',
      body: task.dueDate != null
          ? 'Due ${_formatDate(task.dueDate!)}'
          : 'Reminder for your task.',
      entityId: task.id,
      entityType: 'task',
      routePath: '${RouteConstants.tasks}/${task.id}/edit',
      scheduledAt: reminderAt,
      dedupeKey: 'task_reminder_${task.id}_${reminderAt.millisecondsSinceEpoch}',
    );
  }

  CreateNotificationParams? _meetingReminder(
    Meeting meeting,
    DateTime now,
    DateTime windowEnd,
  ) {
    if (meeting.status != MeetingStatus.scheduled) return null;

    final reminderAt = meeting.reminderAt ?? meeting.startTime;
    if (!_isInWindow(reminderAt, now, windowEnd)) return null;

    return CreateNotificationParams(
      type: NotificationType.meetingReminder,
      title: 'Meeting reminder: ${meeting.title}',
      body: 'Starts at ${_formatTime(meeting.startTime)}'
          '${meeting.location != null ? ' · ${meeting.location}' : ''}',
      entityId: meeting.id,
      entityType: 'meeting',
      routePath: '${RouteConstants.meetings}/${meeting.id}',
      scheduledAt: reminderAt,
      dedupeKey:
          'meeting_reminder_${meeting.id}_${reminderAt.millisecondsSinceEpoch}',
    );
  }

  CreateNotificationParams? _goalDeadlineReminder(
    Goal goal,
    DateTime now,
    DateTime windowEnd,
  ) {
    final deadline = goal.deadline;
    if (deadline == null || goal.status == GoalStatus.completed) return null;

    final reminderAt = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      9,
    );
    if (!_isInWindow(reminderAt, now, windowEnd)) return null;

    return CreateNotificationParams(
      type: NotificationType.goalDeadline,
      title: 'Goal deadline: ${goal.title}',
      body: 'Deadline is ${_formatDate(deadline)}.',
      entityId: goal.id,
      entityType: 'goal',
      routePath: RouteConstants.goals,
      scheduledAt: reminderAt,
      dedupeKey: 'goal_deadline_${goal.id}_${deadline.year}${deadline.month}${deadline.day}',
    );
  }

  CreateNotificationParams? _contactBirthdayReminder(
    Contact contact,
    DateTime now,
  ) {
    final birthday = contact.birthday;
    if (birthday == null) return null;
    if (!_isBirthdayToday(birthday, now)) return null;

    final reminderAt = DateTime(now.year, now.month, now.day, 8);
    return CreateNotificationParams(
      type: NotificationType.birthdayReminder,
      title: 'Birthday today: ${contact.fullName}',
      body: 'Send ${contact.firstName} a birthday message.',
      entityId: contact.id,
      entityType: 'contact',
      routePath: '${RouteConstants.crm}/contacts/${contact.id}',
      scheduledAt: reminderAt,
      dedupeKey:
          'birthday_contact_${contact.id}_${now.year}${now.month}${now.day}',
    );
  }

  CreateNotificationParams? _calendarBirthdayReminder(
    CalendarEvent event,
    DateTime now,
  ) {
    if (!_isBirthdayToday(event.startTime, now)) return null;

    final reminderAt = DateTime(now.year, now.month, now.day, 8);
    return CreateNotificationParams(
      type: NotificationType.birthdayReminder,
      title: 'Birthday today: ${event.title}',
      body: event.description.isNotEmpty
          ? event.description
          : 'Celebrate this special day.',
      entityId: event.id,
      entityType: 'calendar_event',
      routePath: RouteConstants.calendar,
      scheduledAt: reminderAt,
      dedupeKey:
          'birthday_event_${event.id}_${now.year}${now.month}${now.day}',
    );
  }

  bool _isInWindow(DateTime time, DateTime now, DateTime windowEnd) {
    return !time.isAfter(windowEnd) &&
        !time.isBefore(now.subtract(const Duration(days: 1)));
  }

  bool _isBirthdayToday(DateTime birthday, DateTime now) {
    return birthday.month == now.month && birthday.day == now.day;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
