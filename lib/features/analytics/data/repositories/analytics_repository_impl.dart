import 'package:personal_os_dashboard/features/analytics/data/services/analytics_aggregator.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_report.dart';
import 'package:personal_os_dashboard/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:personal_os_dashboard/features/goals/domain/repositories/goals_repository.dart';
import 'package:personal_os_dashboard/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:personal_os_dashboard/features/projects/domain/repositories/projects_repository.dart';
import 'package:personal_os_dashboard/features/tasks/domain/repositories/tasks_repository.dart';

final class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl({
    required TasksRepository tasksRepository,
    required GoalsRepository goalsRepository,
    required ProjectsRepository projectsRepository,
    required MeetingsRepository meetingsRepository,
    AnalyticsAggregator aggregator = const AnalyticsAggregator(),
  })  : _tasksRepository = tasksRepository,
        _goalsRepository = goalsRepository,
        _projectsRepository = projectsRepository,
        _meetingsRepository = meetingsRepository,
        _aggregator = aggregator;

  final TasksRepository _tasksRepository;
  final GoalsRepository _goalsRepository;
  final ProjectsRepository _projectsRepository;
  final MeetingsRepository _meetingsRepository;
  final AnalyticsAggregator _aggregator;

  @override
  Future<AnalyticsReport> getReport({
    required String userId,
    required ReportPeriod period,
  }) async {
    final tasks = await _tasksRepository.getTasks(userId: userId);
    final goals = await _goalsRepository.getGoals(userId: userId);
    final projects = await _projectsRepository.getProjects(userId: userId);
    final meetings = await _meetingsRepository.getMeetings(userId: userId);

    return _aggregator.buildReport(
      period: period,
      tasks: tasks,
      goals: goals,
      projects: projects,
      meetings: meetings,
    );
  }
}

AnalyticsRepository createAnalyticsRepository({
  required TasksRepository tasksRepository,
  required GoalsRepository goalsRepository,
  required ProjectsRepository projectsRepository,
  required MeetingsRepository meetingsRepository,
}) {
  return AnalyticsRepositoryImpl(
    tasksRepository: tasksRepository,
    goalsRepository: goalsRepository,
    projectsRepository: projectsRepository,
    meetingsRepository: meetingsRepository,
  );
}
