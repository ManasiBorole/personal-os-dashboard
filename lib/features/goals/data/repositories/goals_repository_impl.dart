import 'package:personal_os_dashboard/features/goals/data/datasources/goals_data_source.dart';
import 'package:personal_os_dashboard/features/goals/data/datasources/local_goals_data_source.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';
import 'package:personal_os_dashboard/features/goals/domain/repositories/goals_repository.dart';

/// Repository implementation delegating to a [GoalsDataSource].
final class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl(this._dataSource);

  final GoalsDataSource _dataSource;

  @override
  Future<List<Goal>> getGoals({required String userId}) async {
    final models = await _dataSource.getGoals(userId: userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Goal> getGoalById({required String id}) async {
    final model = await _dataSource.getGoalById(id: id);
    return model.toEntity();
  }

  @override
  Future<Goal> createGoal({
    required String userId,
    required CreateGoalParams params,
  }) async {
    final model = await _dataSource.createGoal(userId: userId, params: params);
    return model.toEntity();
  }

  @override
  Future<Goal> updateGoal({
    required String userId,
    required UpdateGoalParams params,
  }) async {
    final model = await _dataSource.updateGoal(userId: userId, params: params);
    return model.toEntity();
  }

  @override
  Future<void> deleteGoal({required String id}) async {
    await _dataSource.deleteGoal(id: id);
  }
}

/// Fallback repository backed by in-memory local storage.
final class UnconfiguredGoalsRepository implements GoalsRepository {
  UnconfiguredGoalsRepository()
      : _delegate = GoalsRepositoryImpl(LocalGoalsDataSource());

  final GoalsRepositoryImpl _delegate;

  @override
  Future<List<Goal>> getGoals({required String userId}) =>
      _delegate.getGoals(userId: userId);

  @override
  Future<Goal> getGoalById({required String id}) =>
      _delegate.getGoalById(id: id);

  @override
  Future<Goal> createGoal({
    required String userId,
    required CreateGoalParams params,
  }) =>
      _delegate.createGoal(userId: userId, params: params);

  @override
  Future<Goal> updateGoal({
    required String userId,
    required UpdateGoalParams params,
  }) =>
      _delegate.updateGoal(userId: userId, params: params);

  @override
  Future<void> deleteGoal({required String id}) =>
      _delegate.deleteGoal(id: id);
}

/// Factory for creating the appropriate [GoalsRepository].
GoalsRepository createGoalsRepository({
  required bool isSupabaseReady,
  required GoalsDataSource remoteDataSource,
}) {
  if (isSupabaseReady) {
    return GoalsRepositoryImpl(remoteDataSource);
  }

  return UnconfiguredGoalsRepository();
}
