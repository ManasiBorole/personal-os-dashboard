import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// Report time range granularity.
enum ReportPeriod {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  const ReportPeriod(this.label);

  final String label;
}

/// Single chart data point with label and value.
final class ChartDataPoint extends Entity {
  const ChartDataPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}

/// Task completion breakdown and trend.
final class TaskCompletionStats extends Entity {
  const TaskCompletionStats({
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.overdue,
    required this.completionRate,
    required this.trend,
  });

  final int completed;
  final int inProgress;
  final int pending;
  final int overdue;
  final double completionRate;
  final List<ChartDataPoint> trend;

  int get total => completed + inProgress + pending + overdue;

  @override
  List<Object?> get props =>
      [completed, inProgress, pending, overdue, completionRate, trend];
}

/// Goal progress for bar chart.
final class GoalProgressPoint extends Entity {
  const GoalProgressPoint({
    required this.id,
    required this.title,
    required this.progress,
  });

  final String id;
  final String title;
  final double progress;

  @override
  List<Object?> get props => [id, title, progress];
}

/// Project count by status.
final class ProjectStatusPoint extends Entity {
  const ProjectStatusPoint({
    required this.status,
    required this.count,
  });

  final String status;
  final int count;

  @override
  List<Object?> get props => [status, count];
}

/// Meeting activity per time bucket.
final class MeetingsStats extends Entity {
  const MeetingsStats({
    required this.scheduled,
    required this.completed,
    required this.cancelled,
    required this.trend,
  });

  final int scheduled;
  final int completed;
  final int cancelled;
  final List<ChartDataPoint> trend;

  int get total => scheduled + completed + cancelled;

  @override
  List<Object?> get props => [scheduled, completed, cancelled, trend];
}

/// Productivity score trend.
final class ProductivityStats extends Entity {
  const ProductivityStats({
    required this.score,
    required this.trend,
    required this.changePercent,
  });

  final int score;
  final List<ChartDataPoint> trend;
  final double changePercent;

  @override
  List<Object?> get props => [score, trend, changePercent];
}

/// Full analytics report for a time period.
final class AnalyticsReport extends Entity {
  const AnalyticsReport({
    required this.period,
    required this.generatedAt,
    required this.taskCompletion,
    required this.goalProgress,
    required this.projectStatus,
    required this.meetings,
    required this.productivity,
  });

  final ReportPeriod period;
  final DateTime generatedAt;
  final TaskCompletionStats taskCompletion;
  final List<GoalProgressPoint> goalProgress;
  final List<ProjectStatusPoint> projectStatus;
  final MeetingsStats meetings;
  final ProductivityStats productivity;

  @override
  List<Object?> get props => [
        period,
        generatedAt,
        taskCompletion,
        goalProgress,
        projectStatus,
        meetings,
        productivity,
      ];
}
