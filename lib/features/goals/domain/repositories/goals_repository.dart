import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';

/// Contract for goal persistence and retrieval.
abstract interface class GoalsRepository {
  Future<List<Goal>> getGoals({required String userId});

  Future<Goal> getGoalById({required String id});

  Future<Goal> createGoal({
    required String userId,
    required CreateGoalParams params,
  });

  Future<Goal> updateGoal({
    required String userId,
    required UpdateGoalParams params,
  });

  Future<void> deleteGoal({required String id});
}
