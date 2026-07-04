import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/features/goals/data/datasources/local_goals_data_source.dart';
import 'package:personal_os_dashboard/features/goals/data/repositories/goals_repository_impl.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal_params.dart';
import 'package:personal_os_dashboard/features/goals/domain/usecases/goal_usecases.dart';

void main() {
  late GoalsRepositoryImpl repository;

  setUp(() {
    repository = GoalsRepositoryImpl(LocalGoalsDataSource());
  });

  group('Goal use cases', () {
    test('loads seeded goals for local user', () async {
      final result = await GetGoalsUseCase(repository).call('local-user');

      expect(result.isSuccess, isTrue);
      result.when(
        success: (goals) => expect(goals.length, greaterThanOrEqualTo(3)),
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('creates, updates, and deletes a goal', () async {
      const userId = 'test-user';

      final createResult = await CreateGoalUseCase(repository).call(
        CreateGoalRequest(
          userId: userId,
          goal: CreateGoalParams(
            title: 'Test goal',
            description: 'Test description',
            category: GoalCategory.career.name,
            priority: GoalPriority.high.name,
            deadline: DateTime.now().add(const Duration(days: 30)),
            progress: 0.25,
            status: GoalStatus.active.name,
          ),
        ),
      );

      late String goalId;
      createResult.when(
        success: (goal) => goalId = goal.id,
        onFailure: (_) => fail('Create failed'),
      );

      final updateResult = await UpdateGoalUseCase(repository).call(
        UpdateGoalRequest(
          userId: userId,
          goal: UpdateGoalParams(
            id: goalId,
            title: 'Updated goal',
            description: 'Updated description',
            category: GoalCategory.career.name,
            priority: GoalPriority.medium.name,
            deadline: null,
            progress: 0.5,
            status: GoalStatus.active.name,
            clearDeadline: true,
          ),
        ),
      );

      updateResult.when(
        success: (goal) {
          expect(goal.title, 'Updated goal');
          expect(goal.progress, 0.5);
          expect(goal.deadline, isNull);
        },
        onFailure: (_) => fail('Update failed'),
      );

      final deleteResult = await DeleteGoalUseCase(repository).call(goalId);
      expect(deleteResult.isSuccess, isTrue);

      final getResult = await GetGoalByIdUseCase(repository).call(goalId);
      expect(getResult.isFailure, isTrue);
    });
  });
}
