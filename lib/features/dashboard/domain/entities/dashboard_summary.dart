import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// Aggregated dashboard data for the command center view.
final class DashboardSummary extends Entity {
  const DashboardSummary({
    required this.todayOverview,
    required this.taskSummary,
    required this.goals,
    required this.projects,
    required this.meetings,
    required this.calendarEvents,
    required this.quickActions,
    required this.notes,
    required this.analytics,
  });

  final TodayOverview todayOverview;
  final TaskSummary taskSummary;
  final List<GoalProgressItem> goals;
  final List<ProjectProgressItem> projects;
  final List<UpcomingMeetingItem> meetings;
  final List<CalendarPreviewItem> calendarEvents;
  final List<QuickActionItem> quickActions;
  final List<RecentNoteItem> notes;
  final List<AnalyticsMetric> analytics;

  @override
  List<Object?> get props => [
        todayOverview,
        taskSummary,
        goals,
        projects,
        meetings,
        calendarEvents,
        quickActions,
        notes,
        analytics,
      ];
}

/// High-level snapshot for the current day.
final class TodayOverview extends Entity {
  const TodayOverview({
    required this.greeting,
    required this.date,
    required this.completedTasks,
    required this.totalTasks,
    required this.meetingsCount,
    required this.focusLabel,
    required this.productivityScore,
  });

  final String greeting;
  final DateTime date;
  final int completedTasks;
  final int totalTasks;
  final int meetingsCount;
  final String focusLabel;
  final int productivityScore;

  double get taskCompletionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  @override
  List<Object?> get props => [
        greeting,
        date,
        completedTasks,
        totalTasks,
        meetingsCount,
        focusLabel,
        productivityScore,
      ];
}

/// Task counts grouped by status.
final class TaskSummary extends Entity {
  const TaskSummary({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.overdue,
    required this.dueToday,
    required this.highPriority,
  });

  final int total;
  final int completed;
  final int inProgress;
  final int overdue;
  final int dueToday;
  final int highPriority;

  @override
  List<Object?> get props =>
      [total, completed, inProgress, overdue, dueToday, highPriority];
}

/// Goal progress for dashboard display.
final class GoalProgressItem extends Entity {
  const GoalProgressItem({
    required this.id,
    required this.title,
    required this.progress,
    required this.deadline,
    required this.status,
  });

  final String id;
  final String title;
  final double progress;
  final DateTime? deadline;
  final String status;

  @override
  List<Object?> get props => [id, title, progress, deadline, status];
}

/// Project progress for dashboard display.
final class ProjectProgressItem extends Entity {
  const ProjectProgressItem({
    required this.id,
    required this.name,
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
    required this.status,
  });

  final String id;
  final String name;
  final double progress;
  final int completedTasks;
  final int totalTasks;
  final String status;

  @override
  List<Object?> get props =>
      [id, name, progress, completedTasks, totalTasks, status];
}

/// Upcoming meeting entry.
final class UpcomingMeetingItem extends Entity {
  const UpcomingMeetingItem({
    required this.id,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    required this.location,
    required this.attendeeCount,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final String? location;
  final int attendeeCount;

  @override
  List<Object?> get props =>
      [id, title, startTime, durationMinutes, location, attendeeCount];
}

/// Calendar event preview entry.
final class CalendarPreviewItem extends Entity {
  const CalendarPreviewItem({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    required this.category,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String category;

  @override
  List<Object?> get props =>
      [id, title, startTime, endTime, isAllDay, category];
}

/// Shortcut action for common workflows.
final class QuickActionItem extends Entity {
  const QuickActionItem({
    required this.id,
    required this.label,
    required this.iconName,
    required this.route,
    required this.colorIndex,
  });

  final String id;
  final String label;
  final String iconName;
  final String route;
  final int colorIndex;

  @override
  List<Object?> get props => [id, label, iconName, route, colorIndex];
}

/// Recently updated note preview.
final class RecentNoteItem extends Entity {
  const RecentNoteItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    required this.tags,
  });

  final String id;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final List<String> tags;

  @override
  List<Object?> get props => [id, title, preview, updatedAt, tags];
}

/// Analytics metric card data.
final class AnalyticsMetric extends Entity {
  const AnalyticsMetric({
    required this.id,
    required this.label,
    required this.value,
    required this.changePercent,
    required this.trend,
    required this.iconName,
    required this.sparkline,
  });

  final String id;
  final String label;
  final String value;
  final double changePercent;
  final AnalyticsTrend trend;
  final String iconName;
  final List<double> sparkline;

  @override
  List<Object?> get props =>
      [id, label, value, changePercent, trend, iconName, sparkline];
}

enum AnalyticsTrend { up, down, neutral }
