import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/features/tasks/data/datasources/local_tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';
import 'package:personal_os_dashboard/features/tasks/domain/usecases/task_usecases.dart';

void main() {
  late TasksRepositoryImpl repository;

  setUp(() {
    repository = TasksRepositoryImpl(LocalTasksDataSource());
  });

  group('Task use cases', () {
    test('loads seeded tasks for local user', () async {
      final result = await GetTasksUseCase(repository).call(
        (userId: 'local-user', projectId: null),
      );

      expect(result.isSuccess, isTrue);
      result.when(
        success: (tasks) => expect(tasks.length, greaterThanOrEqualTo(3)),
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('filters tasks by project', () async {
      final result = await GetTasksUseCase(repository).call(
        (userId: 'local-user', projectId: 'proj-local-1'),
      );

      result.when(
        success: (tasks) {
          expect(tasks, isNotEmpty);
          expect(tasks.every((t) => t.projectId == 'proj-local-1'), isTrue);
        },
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('creates, updates, completes, and deletes a task', () async {
      const userId = 'test-user';

      final createResult = await CreateTaskUseCase(repository).call(
        CreateTaskRequest(
          userId: userId,
          task: CreateTaskParams(
            title: 'Test task',
            description: 'Test description',
            status: TaskStatus.pending.storageValue,
            priority: TaskPriority.high.name,
            projectId: 'proj-local-1',
            parentTaskId: null,
            dueDate: DateTime.now().add(const Duration(days: 7)),
            reminderAt: DateTime.now().add(const Duration(days: 6)),
            checklist: const [
              ChecklistItem(id: 'cl-test', title: 'Step 1', isCompleted: false),
            ],
            subtasks: const ['Subtask A'],
          ),
        ),
      );

      late String taskId;
      createResult.when(
        success: (task) {
          taskId = task.id;
          expect(task.title, 'Test task');
          expect(task.subtasks.length, 1);
          expect(task.checklist.length, 1);
        },
        onFailure: (_) => fail('Create failed'),
      );

      final updateResult = await UpdateTaskUseCase(repository).call(
        UpdateTaskRequest(
          userId: userId,
          task: UpdateTaskParams(
            id: taskId,
            title: 'Updated task',
            description: 'Updated description',
            status: TaskStatus.inProgress.storageValue,
            priority: TaskPriority.medium.name,
            projectId: null,
            dueDate: null,
            reminderAt: null,
            checklist: const [],
            subtasks: const [],
            clearProjectId: true,
            clearDueDate: true,
            clearReminder: true,
          ),
        ),
      );

      updateResult.when(
        success: (task) {
          expect(task.title, 'Updated task');
          expect(task.status, TaskStatus.inProgress);
          expect(task.projectId, isNull);
        },
        onFailure: (_) => fail('Update failed'),
      );

      final completeResult = await CompleteTaskUseCase(repository).call(taskId);
      completeResult.when(
        success: (task) => expect(task.status, TaskStatus.completed),
        onFailure: (_) => fail('Complete failed'),
      );

      final deleteResult = await DeleteTaskUseCase(repository).call(taskId);
      expect(deleteResult.isSuccess, isTrue);

      final getResult = await GetTaskByIdUseCase(repository).call(taskId);
      expect(getResult.isFailure, isTrue);
    });
  });
}
