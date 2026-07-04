import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/features/goals/data/datasources/goals_data_source.dart';
import 'package:personal_os_dashboard/features/goals/data/models/goal_model.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';

/// Supabase-backed goals data source.
final class SupabaseGoalsDataSource implements GoalsDataSource {
  SupabaseGoalsDataSource(this._database);

  final DatabaseRemoteDataSource _database;

  @override
  Future<List<GoalModel>> getGoals({required String userId}) async {
    final rows = await _database.select(
      table: ApiConstants.goalsTable,
      filters: {'user_id': userId},
      orderBy: 'updated_at',
      ascending: false,
    );

    return rows.map(GoalModel.fromJson).toList();
  }

  @override
  Future<GoalModel> getGoalById({required String id}) async {
    final row = await _database.selectById(
      table: ApiConstants.goalsTable,
      id: id,
    );

    return GoalModel.fromJson(row);
  }

  @override
  Future<GoalModel> createGoal({
    required String userId,
    required CreateGoalParams params,
  }) async {
    final now = DateTime.now();
    final row = await _database.insert(
      table: ApiConstants.goalsTable,
      data: {
        'user_id': userId,
        'title': params.title.trim(),
        'description': params.description.trim(),
        'category': params.category,
        'priority': params.priority,
        'deadline': params.deadline?.toIso8601String(),
        'progress': (params.progress * 100).round(),
        'status': params.status,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );

    return GoalModel.fromJson(row);
  }

  @override
  Future<GoalModel> updateGoal({
    required String userId,
    required UpdateGoalParams params,
  }) async {
    final row = await _database.update(
      table: ApiConstants.goalsTable,
      data: {
        'title': params.title.trim(),
        'description': params.description.trim(),
        'category': params.category,
        'priority': params.priority,
        'deadline':
            params.clearDeadline ? null : params.deadline?.toIso8601String(),
        'progress': (params.progress * 100).round(),
        'status': params.status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {
        'id': params.id,
        'user_id': userId,
      },
    );

    return GoalModel.fromJson(row);
  }

  @override
  Future<void> deleteGoal({required String id}) async {
    await _database.delete(
      table: ApiConstants.goalsTable,
      filters: {'id': id},
    );
  }
}
