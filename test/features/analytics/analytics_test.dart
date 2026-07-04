import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/features/analytics/data/services/analytics_aggregator.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_params.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_report.dart';
import 'package:personal_os_dashboard/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:personal_os_dashboard/features/analytics/domain/usecases/analytics_usecases.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';

void main() {
  const aggregator = AnalyticsAggregator();
  final now = DateTime.now();

  Task task({
    required String id,
    TaskStatus status = TaskStatus.pending,
    DateTime? updatedAt,
    String? parentTaskId,
  }) {
    return Task(
      id: id,
      userId: 'user',
      projectId: null,
      parentTaskId: parentTaskId,
      title: 'Task $id',
      description: '',
      status: status,
      priority: TaskPriority.medium,
      dueDate: null,
      reminderAt: null,
      checklist: const [],
      subtasks: const [],
      projectName: null,
      createdAt: now,
      updatedAt: updatedAt ?? now,
    );
  }

  Goal goal({
    required String id,
    required String title,
    double progress = 0.5,
  }) {
    return Goal(
      id: id,
      userId: 'user',
      title: title,
      description: '',
      category: GoalCategory.career,
      priority: GoalPriority.medium,
      deadline: null,
      progress: progress,
      status: GoalStatus.active,
      createdAt: now,
      updatedAt: now,
    );
  }

  Project project({
    required String id,
    ProjectStatus status = ProjectStatus.active,
    double progress = 0.6,
  }) {
    return Project(
      id: id,
      userId: 'user',
      name: 'Project $id',
      description: '',
      status: status,
      client: const ClientDetails(
        name: '',
        email: '',
        company: '',
        phone: '',
      ),
      budget: const ProjectBudget(amount: 0, currency: 'USD', spent: 0),
      timeline: const ProjectTimeline(startDate: null, endDate: null),
      progress: progress,
      completedTasks: 0,
      totalTasks: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Meeting meeting({
    required String id,
    MeetingStatus status = MeetingStatus.scheduled,
    DateTime? startTime,
  }) {
    return Meeting(
      id: id,
      userId: 'user',
      title: 'Meeting $id',
      agenda: '',
      participants: const [],
      startTime: startTime ?? now,
      durationMinutes: 30,
      location: null,
      notes: '',
      followUp: '',
      attachments: const [],
      reminderAt: null,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('AnalyticsAggregator', () {
    test('aggregates task completion and excludes subtasks', () {
      final report = aggregator.buildReport(
        period: ReportPeriod.weekly,
        tasks: [
          task(id: '1', status: TaskStatus.completed),
          task(id: '2', status: TaskStatus.inProgress),
          task(id: '3', status: TaskStatus.pending),
          task(
            id: '4',
            status: TaskStatus.completed,
            parentTaskId: '1',
          ),
        ],
        goals: const [],
        projects: const [],
        meetings: const [],
      );

      expect(report.taskCompletion.completed, 1);
      expect(report.taskCompletion.inProgress, 1);
      expect(report.taskCompletion.pending, 1);
      expect(report.taskCompletion.total, 3);
      expect(report.taskCompletion.completionRate, closeTo(1 / 3, 0.01));
      expect(report.taskCompletion.trend.length, 8);
    });

    test('maps goal progress to percentage scale', () {
      final report = aggregator.buildReport(
        period: ReportPeriod.daily,
        tasks: const [],
        goals: [
          goal(id: 'g1', title: 'Alpha', progress: 0.75),
          goal(id: 'g2', title: 'Beta', progress: 0.25),
        ],
        projects: const [],
        meetings: const [],
      );

      expect(report.goalProgress.length, 2);
      expect(report.goalProgress.first.title, 'Alpha');
      expect(report.goalProgress.first.progress, 75);
      expect(report.goalProgress.last.progress, 25);
    });

    test('groups projects by status label', () {
      final report = aggregator.buildReport(
        period: ReportPeriod.monthly,
        tasks: const [],
        goals: const [],
        projects: [
          project(id: 'p1', status: ProjectStatus.active),
          project(id: 'p2', status: ProjectStatus.active),
          project(id: 'p3', status: ProjectStatus.completed),
        ],
        meetings: const [],
      );

      final active = report.projectStatus
          .firstWhere((point) => point.status == ProjectStatus.active.label);
      final completed = report.projectStatus
          .firstWhere((point) => point.status == ProjectStatus.completed.label);

      expect(active.count, 2);
      expect(completed.count, 1);
    });

    test('builds meeting and productivity trends for each period', () {
      for (final period in ReportPeriod.values) {
        final report = aggregator.buildReport(
          period: period,
          tasks: [task(id: '1', status: TaskStatus.completed)],
          goals: [goal(id: 'g1', title: 'Goal', progress: 0.8)],
          projects: [project(id: 'p1', progress: 0.5)],
          meetings: [
            meeting(id: 'm1', status: MeetingStatus.completed),
            meeting(id: 'm2', status: MeetingStatus.scheduled),
          ],
        );

        final expectedBuckets = switch (period) {
          ReportPeriod.daily => 7,
          ReportPeriod.weekly => 8,
          ReportPeriod.monthly => 12,
          ReportPeriod.yearly => 5,
        };

        expect(report.period, period);
        expect(report.meetings.trend.length, expectedBuckets);
        expect(report.productivity.trend.length, expectedBuckets);
        expect(report.productivity.score, inInclusiveRange(0, 100));
      }
    });
  });

  group('GetAnalyticsReportUseCase', () {
    test('returns analytics report for requested period', () async {
      final expected = aggregator.buildReport(
        period: ReportPeriod.yearly,
        tasks: [task(id: '1', status: TaskStatus.completed)],
        goals: const [],
        projects: const [],
        meetings: const [],
      );

      final useCase = GetAnalyticsReportUseCase(
        _FakeAnalyticsRepository(expected),
      );

      final result = await useCase.call(
        const GetAnalyticsReportParams(
          userId: 'local-user',
          period: ReportPeriod.yearly,
        ),
      );

      expect(result.isSuccess, isTrue);
      result.when(
        success: (report) {
          expect(report.period, ReportPeriod.yearly);
          expect(report.taskCompletion.completed, 1);
        },
        onFailure: (_) => fail('Expected success'),
      );
    });
  });
}

class _FakeAnalyticsRepository implements AnalyticsRepository {
  _FakeAnalyticsRepository(this._report);

  final AnalyticsReport _report;

  @override
  Future<AnalyticsReport> getReport({
    required String userId,
    required ReportPeriod period,
  }) async {
    return _report.copyWith(period: period);
  }
}

extension on AnalyticsReport {
  AnalyticsReport copyWith({ReportPeriod? period}) {
    return AnalyticsReport(
      period: period ?? this.period,
      generatedAt: generatedAt,
      taskCompletion: taskCompletion,
      goalProgress: goalProgress,
      projectStatus: projectStatus,
      meetings: meetings,
      productivity: productivity,
    );
  }
}
