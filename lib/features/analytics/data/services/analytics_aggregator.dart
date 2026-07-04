import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_report.dart';

/// Aggregates module data into analytics report chart data.
final class AnalyticsAggregator {
  const AnalyticsAggregator();

  AnalyticsReport buildReport({
    required ReportPeriod period,
    required List<Task> tasks,
    required List<Goal> goals,
    required List<Project> projects,
    required List<Meeting> meetings,
  }) {
    final now = DateTime.now();
    final buckets = _bucketRanges(period, now);
    final topLevelTasks = tasks.where((t) => !t.isSubtask).toList();

    final completed = topLevelTasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final inProgress = topLevelTasks
        .where((t) => t.status == TaskStatus.inProgress)
        .length;
    final pending = topLevelTasks
        .where((t) => t.status == TaskStatus.pending)
        .length;
    final overdue = topLevelTasks.where((t) => t.isOverdue).length;
    final total = topLevelTasks.length;

    final taskTrend = buckets.map((bucket) {
      final count = topLevelTasks.where((t) {
        if (t.status != TaskStatus.completed) return false;
        return _inBucket(t.updatedAt, bucket.start, bucket.end);
      }).length;
      return ChartDataPoint(label: bucket.label, value: count.toDouble());
    }).toList();

    final goalProgress = goals
        .map(
          (g) => GoalProgressPoint(
            id: g.id,
            title: g.title,
            progress: (g.progress * 100).clamp(0, 100),
          ),
        )
        .toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));

    final statusCounts = <String, int>{};
    for (final project in projects) {
      final label = project.status.label;
      statusCounts[label] = (statusCounts[label] ?? 0) + 1;
    }
    final projectStatus = statusCounts.entries
        .map((e) => ProjectStatusPoint(status: e.key, count: e.value))
        .toList();

    final scheduled =
        meetings.where((m) => m.status == MeetingStatus.scheduled).length;
    final meetingsCompleted =
        meetings.where((m) => m.status == MeetingStatus.completed).length;
    final cancelled =
        meetings.where((m) => m.status == MeetingStatus.cancelled).length;

    final meetingTrend = buckets.map((bucket) {
      final count = meetings.where((m) {
        return _inBucket(m.startTime, bucket.start, bucket.end);
      }).length;
      return ChartDataPoint(label: bucket.label, value: count.toDouble());
    }).toList();

    final productivityTrend = buckets.map((bucket) {
      final bucketTasks = topLevelTasks.where(
        (t) => _inBucket(t.updatedAt, bucket.start, bucket.end),
      );
      final bucketCompleted = bucketTasks
          .where((t) => t.status == TaskStatus.completed)
          .length;
      final bucketTotal = bucketTasks.length;
      final taskScore =
          bucketTotal == 0 ? 0.0 : bucketCompleted / bucketTotal * 100;

      final bucketMeetings = meetings.where(
        (m) => _inBucket(m.startTime, bucket.start, bucket.end),
      );
      final meetingScore = bucketMeetings.isEmpty
          ? 50.0
          : bucketMeetings
                  .where((m) => m.status == MeetingStatus.completed)
                  .length /
              bucketMeetings.length *
              100;

      final goalAvg = goals.isEmpty
          ? 50.0
          : goals.map((g) => g.progress * 100).reduce((a, b) => a + b) /
              goals.length;

      final score = (taskScore * 0.5 + meetingScore * 0.25 + goalAvg * 0.25)
          .clamp(0.0, 100.0);
      return ChartDataPoint(label: bucket.label, value: score);
    }).toList();

    final productivityScore = _overallProductivityScore(
      taskCompletionRate: total == 0 ? 0 : completed / total,
      goalProgressAvg: goals.isEmpty
          ? 0
          : goals.map((g) => g.progress).reduce((a, b) => a + b) / goals.length,
      projectProgressAvg: projects.isEmpty
          ? 0
          : projects.map((p) => p.progress).reduce((a, b) => a + b) /
              projects.length,
      meetingCompletionRate: meetings.isEmpty
          ? 0
          : meetingsCompleted / meetings.length,
    );

    final changePercent = productivityTrend.length >= 2
        ? productivityTrend.last.value - productivityTrend.first.value
        : 0.0;

    return AnalyticsReport(
      period: period,
      generatedAt: now,
      taskCompletion: TaskCompletionStats(
        completed: completed,
        inProgress: inProgress,
        pending: pending,
        overdue: overdue,
        completionRate: total == 0 ? 0 : completed / total,
        trend: taskTrend,
      ),
      goalProgress: goalProgress.take(8).toList(),
      projectStatus: projectStatus,
      meetings: MeetingsStats(
        scheduled: scheduled,
        completed: meetingsCompleted,
        cancelled: cancelled,
        trend: meetingTrend,
      ),
      productivity: ProductivityStats(
        score: productivityScore,
        trend: productivityTrend,
        changePercent: changePercent,
      ),
    );
  }

  int _overallProductivityScore({
    required double taskCompletionRate,
    required double goalProgressAvg,
    required double projectProgressAvg,
    required double meetingCompletionRate,
  }) {
    final score = taskCompletionRate * 40 +
        goalProgressAvg * 25 +
        projectProgressAvg * 20 +
        meetingCompletionRate * 15;
    return score.round().clamp(0, 100);
  }

  bool _inBucket(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && date.isBefore(end);
  }

  List<_Bucket> _bucketRanges(ReportPeriod period, DateTime now) {
    return switch (period) {
      ReportPeriod.daily => _dailyBuckets(now),
      ReportPeriod.weekly => _weeklyBuckets(now),
      ReportPeriod.monthly => _monthlyBuckets(now),
      ReportPeriod.yearly => _yearlyBuckets(now),
    };
  }

  List<_Bucket> _dailyBuckets(DateTime now) {
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i));
      final end = day.add(const Duration(days: 1));
      final label = _weekdayLabel(day.weekday);
      return _Bucket(label: label, start: day, end: end);
    });
  }

  List<_Bucket> _weeklyBuckets(DateTime now) {
    return List.generate(8, (i) {
      final start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: (7 - i) * 7));
      final end = start.add(const Duration(days: 7));
      return _Bucket(label: 'W${i + 1}', start: start, end: end);
    });
  }

  List<_Bucket> _monthlyBuckets(DateTime now) {
    return List.generate(12, (i) {
      final month = DateTime(now.year, now.month - (11 - i), 1);
      final end = DateTime(month.year, month.month + 1, 1);
      return _Bucket(
        label: _monthLabel(month.month),
        start: month,
        end: end,
      );
    });
  }

  List<_Bucket> _yearlyBuckets(DateTime now) {
    return List.generate(5, (i) {
      final year = now.year - (4 - i);
      final start = DateTime(year, 1, 1);
      final end = DateTime(year + 1, 1, 1);
      return _Bucket(label: '$year', start: start, end: end);
    });
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      DateTime.sunday => 'Sun',
      _ => '',
    };
  }

  String _monthLabel(int month) {
    const labels = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return labels[month - 1];
  }
}

final class _Bucket {
  const _Bucket({
    required this.label,
    required this.start,
    required this.end,
  });

  final String label;
  final DateTime start;
  final DateTime end;
}
