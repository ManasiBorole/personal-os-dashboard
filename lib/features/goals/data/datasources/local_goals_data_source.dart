import 'package:personal_os_dashboard/features/goals/data/datasources/goals_data_source.dart';
import 'package:personal_os_dashboard/features/goals/data/models/goal_model.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';

/// In-memory goals storage for offline/unconfigured environments.
final class LocalGoalsDataSource implements GoalsDataSource {
  final Map<String, GoalModel> _goals = {};

  LocalGoalsDataSource() {
    _seedSampleData();
  }

  void _seedSampleData() {
    final now = DateTime.now();
  const userId = 'local-user';

    final samples = [
      GoalModel(
        id: 'goal-local-1',
        userId: userId,
        title: 'Launch Personal OS v1',
        description: 'Ship the first production-ready version of the dashboard.',
        category: 'career',
        priority: 'high',
        deadline: now.add(const Duration(days: 45)),
        progress: 0.72,
        status: 'active',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      GoalModel(
        id: 'goal-local-2',
        userId: userId,
        title: 'Read 24 books this year',
        description: 'One book every two weeks across fiction and non-fiction.',
        category: 'learning',
        priority: 'medium',
        deadline: DateTime(now.year, 12, 31),
        progress: 0.42,
        status: 'active',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      GoalModel(
        id: 'goal-local-3',
        userId: userId,
        title: 'Improve fitness routine',
        description: 'Work out 4 times per week and track progress.',
        category: 'health',
        priority: 'medium',
        deadline: now.add(const Duration(days: 90)),
        progress: 0.58,
        status: 'active',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    for (final goal in samples) {
      _goals[goal.id] = goal;
    }
  }

  @override
  Future<List<GoalModel>> getGoals({required String userId}) async {
    return _goals.values
        .where((goal) => goal.userId == userId || goal.userId == 'local-user')
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<GoalModel> getGoalById({required String id}) async {
    final goal = _goals[id];
    if (goal == null) {
      throw StateError('Goal not found');
    }
    return goal;
  }

  @override
  Future<GoalModel> createGoal({
    required String userId,
    required CreateGoalParams params,
  }) async {
    final now = DateTime.now();
    final id = 'goal-local-${now.microsecondsSinceEpoch}';
    final goal = GoalModel(
      id: id,
      userId: userId,
      title: params.title.trim(),
      description: params.description.trim(),
      category: params.category,
      priority: params.priority,
      deadline: params.deadline,
      progress: params.progress,
      status: params.status,
      createdAt: now,
      updatedAt: now,
    );

    _goals[id] = goal;
    return goal;
  }

  @override
  Future<GoalModel> updateGoal({
    required String userId,
    required UpdateGoalParams params,
  }) async {
    final existing = await getGoalById(id: params.id);
    final updated = GoalModel(
      id: existing.id,
      userId: userId,
      title: params.title.trim(),
      description: params.description.trim(),
      category: params.category,
      priority: params.priority,
      deadline: params.clearDeadline ? null : params.deadline,
      progress: params.progress,
      status: params.status,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    _goals[updated.id] = updated;
    return updated;
  }

  @override
  Future<void> deleteGoal({required String id}) async {
    _goals.remove(id);
  }
}
