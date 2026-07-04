import 'package:personal_os_dashboard/features/goals/data/models/goal_model.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';

/// Contract for goal data persistence.
abstract interface class GoalsDataSource {
  Future<List<GoalModel>> getGoals({required String userId});

  Future<GoalModel> getGoalById({required String id});

  Future<GoalModel> createGoal({
    required String userId,
    required CreateGoalParams params,
  });

  Future<GoalModel> updateGoal({
    required String userId,
    required UpdateGoalParams params,
  });

  Future<void> deleteGoal({required String id});
}
