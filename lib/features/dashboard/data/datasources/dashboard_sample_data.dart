import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';

/// Curated sample data used when remote data is unavailable.
abstract final class DashboardSampleData {
  static DashboardSummary build({String? userName}) {
    final now = DateTime.now();
    final greeting = _greetingForHour(now.hour, userName);

    return DashboardSummary(
      todayOverview: TodayOverview(
        greeting: greeting,
        date: now,
        completedTasks: 5,
        totalTasks: 12,
        meetingsCount: 3,
        focusLabel: 'Ship dashboard module',
        productivityScore: 78,
      ),
      taskSummary: const TaskSummary(
        total: 42,
        completed: 18,
        inProgress: 14,
        overdue: 3,
        dueToday: 7,
        highPriority: 5,
      ),
      goals: [
        GoalProgressItem(
          id: 'goal-1',
          title: 'Launch Personal OS v1',
          progress: 0.72,
          deadline: now.add(const Duration(days: 45)),
          status: 'On track',
        ),
        GoalProgressItem(
          id: 'goal-2',
          title: 'Read 24 books this year',
          progress: 0.42,
          deadline: DateTime(now.year, 12, 31),
          status: 'In progress',
        ),
        GoalProgressItem(
          id: 'goal-3',
          title: 'Improve fitness routine',
          progress: 0.58,
          deadline: now.add(const Duration(days: 90)),
          status: 'On track',
        ),
      ],
      projects: [
        const ProjectProgressItem(
          id: 'proj-1',
          name: 'Personal OS Dashboard',
          progress: 0.65,
          completedTasks: 26,
          totalTasks: 40,
          status: 'Active',
        ),
        const ProjectProgressItem(
          id: 'proj-2',
          name: 'Marketing Website',
          progress: 0.35,
          completedTasks: 7,
          totalTasks: 20,
          status: 'Active',
        ),
        const ProjectProgressItem(
          id: 'proj-3',
          name: 'Q3 Planning',
          progress: 0.9,
          completedTasks: 18,
          totalTasks: 20,
          status: 'Wrapping up',
        ),
      ],
      meetings: [
        UpcomingMeetingItem(
          id: 'meet-1',
          title: 'Product sync',
          startTime: DateTime(now.year, now.month, now.day, 14, 0),
          durationMinutes: 45,
          location: 'Zoom',
          attendeeCount: 6,
        ),
        UpcomingMeetingItem(
          id: 'meet-2',
          title: 'Design review',
          startTime: DateTime(now.year, now.month, now.day, 16, 30),
          durationMinutes: 30,
          location: 'Conference Room B',
          attendeeCount: 4,
        ),
        UpcomingMeetingItem(
          id: 'meet-3',
          title: '1:1 with mentor',
          startTime: now.add(const Duration(days: 1, hours: 10)),
          durationMinutes: 60,
          location: 'Google Meet',
          attendeeCount: 2,
        ),
      ],
      calendarEvents: [
        CalendarPreviewItem(
          id: 'cal-1',
          title: 'Sprint planning',
          startTime: DateTime(now.year, now.month, now.day, 10, 0),
          endTime: DateTime(now.year, now.month, now.day, 11, 30),
          isAllDay: false,
          category: 'Work',
        ),
        CalendarPreviewItem(
          id: 'cal-2',
          title: 'Gym session',
          startTime: DateTime(now.year, now.month, now.day, 7, 0),
          endTime: DateTime(now.year, now.month, now.day, 8, 0),
          isAllDay: false,
          category: 'Personal',
        ),
        CalendarPreviewItem(
          id: 'cal-3',
          title: 'Team offsite',
          startTime: now.add(const Duration(days: 2)),
          endTime: now.add(const Duration(days: 2, hours: 8)),
          isAllDay: true,
          category: 'Work',
        ),
        CalendarPreviewItem(
          id: 'cal-4',
          title: 'Dentist appointment',
          startTime: now.add(const Duration(days: 3, hours: 15)),
          endTime: now.add(const Duration(days: 3, hours: 16)),
          isAllDay: false,
          category: 'Personal',
        ),
      ],
      quickActions: const [
        QuickActionItem(
          id: 'qa-1',
          label: 'New Task',
          iconName: 'add_task',
          route: RouteConstants.tasks,
          colorIndex: 0,
        ),
        QuickActionItem(
          id: 'qa-2',
          label: 'Add Note',
          iconName: 'note_add',
          route: RouteConstants.notes,
          colorIndex: 1,
        ),
        QuickActionItem(
          id: 'qa-3',
          label: 'Schedule',
          iconName: 'event',
          route: RouteConstants.calendar,
          colorIndex: 2,
        ),
        QuickActionItem(
          id: 'qa-4',
          label: 'New Goal',
          iconName: 'flag',
          route: RouteConstants.goals,
          colorIndex: 3,
        ),
        QuickActionItem(
          id: 'qa-5',
          label: 'Log Meeting',
          iconName: 'groups',
          route: RouteConstants.meetings,
          colorIndex: 4,
        ),
        QuickActionItem(
          id: 'qa-6',
          label: 'Analytics',
          iconName: 'analytics',
          route: RouteConstants.analytics,
          colorIndex: 5,
        ),
      ],
      notes: [
        RecentNoteItem(
          id: 'note-1',
          title: 'Dashboard architecture notes',
          preview:
              'Clean Architecture with Riverpod providers for each widget section...',
          updatedAt: now.subtract(const Duration(hours: 2)),
          tags: const ['dev', 'architecture'],
        ),
        RecentNoteItem(
          id: 'note-2',
          title: 'Weekly priorities',
          preview: '1. Finish auth module 2. Build dashboard 3. Start tasks...',
          updatedAt: now.subtract(const Duration(days: 1)),
          tags: const ['planning'],
        ),
        RecentNoteItem(
          id: 'note-3',
          title: 'Book highlights — Atomic Habits',
          preview: 'Small changes compound. Focus on systems, not goals...',
          updatedAt: now.subtract(const Duration(days: 3)),
          tags: const ['reading', 'habits'],
        ),
      ],
      analytics: const [
        AnalyticsMetric(
          id: 'metric-1',
          label: 'Tasks completed',
          value: '18',
          changePercent: 12.5,
          trend: AnalyticsTrend.up,
          iconName: 'task_alt',
          sparkline: [4, 6, 5, 8, 7, 10, 12, 18],
        ),
        AnalyticsMetric(
          id: 'metric-2',
          label: 'Focus hours',
          value: '6.2h',
          changePercent: 8.0,
          trend: AnalyticsTrend.up,
          iconName: 'timer',
          sparkline: [3, 4, 5, 4.5, 5.5, 6, 5.8, 6.2],
        ),
        AnalyticsMetric(
          id: 'metric-3',
          label: 'Goals on track',
          value: '3/5',
          changePercent: 0,
          trend: AnalyticsTrend.neutral,
          iconName: 'flag',
          sparkline: [2, 2, 3, 3, 3, 3, 3, 3],
        ),
        AnalyticsMetric(
          id: 'metric-4',
          label: 'Meeting load',
          value: '4.5h',
          changePercent: -15.0,
          trend: AnalyticsTrend.down,
          iconName: 'groups',
          sparkline: [6, 5.5, 5, 4.8, 4.5, 4.2, 4.5, 4.5],
        ),
      ],
    );
  }

  static String _greetingForHour(int hour, String? userName) {
    final name = userName?.trim();
    final suffix = name != null && name.isNotEmpty ? ', $name' : '';

    if (hour < 12) return 'Good morning$suffix';
    if (hour < 17) return 'Good afternoon$suffix';
    return 'Good evening$suffix';
  }
}
