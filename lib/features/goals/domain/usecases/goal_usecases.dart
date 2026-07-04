import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';
import 'package:personal_os_dashboard/features/goals/domain/repositories/goals_repository.dart';

final class GetGoalsUseCase implements AsyncUseCase<List<Goal>, String> {
  const GetGoalsUseCase(this._repository);

  final GoalsRepository _repository;

  @override
  Future<Result<List<Goal>>> call(String userId) async {
    try {
      final goals = await _repository.getGoals(userId: userId);
      return Result.success(goals);
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class GetGoalByIdUseCase implements AsyncUseCase<Goal, String> {
  const GetGoalByIdUseCase(this._repository);

  final GoalsRepository _repository;

  @override
  Future<Result<Goal>> call(String id) async {
    try {
      final goal = await _repository.getGoalById(id: id);
      return Result.success(goal);
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class CreateGoalUseCase
    implements AsyncUseCase<Goal, CreateGoalRequest> {
  const CreateGoalUseCase(this._repository);

  final GoalsRepository _repository;

  @override
  Future<Result<Goal>> call(CreateGoalRequest params) async {
    try {
      final goal = await _repository.createGoal(
        userId: params.userId,
        params: params.goal,
      );
      return Result.success(goal);
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class UpdateGoalUseCase
    implements AsyncUseCase<Goal, UpdateGoalRequest> {
  const UpdateGoalUseCase(this._repository);

  final GoalsRepository _repository;

  @override
  Future<Result<Goal>> call(UpdateGoalRequest params) async {
    try {
      final goal = await _repository.updateGoal(
        userId: params.userId,
        params: params.goal,
      );
      return Result.success(goal);
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class DeleteGoalUseCase implements AsyncUseCase<void, String> {
  const DeleteGoalUseCase(this._repository);

  final GoalsRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteGoal(id: id);
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class CreateGoalRequest {
  const CreateGoalRequest({
    required this.userId,
    required this.goal,
  });

  final String userId;
  final CreateGoalParams goal;
}

final class UpdateGoalRequest {
  const UpdateGoalRequest({
    required this.userId,
    required this.goal,
  });

  final String userId;
  final UpdateGoalParams goal;
}
