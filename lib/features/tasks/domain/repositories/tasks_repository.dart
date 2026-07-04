import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';

abstract interface class TasksRepository {
  Future<List<Task>> getTasks({
    required String userId,
    String? projectId,
  });

  Future<Task> getTaskById({required String id});

  Future<Task> createTask({
    required String userId,
    required CreateTaskParams params,
  });

  Future<Task> updateTask({
    required String userId,
    required UpdateTaskParams params,
  });

  Future<Task> completeTask({required String id});

  Future<void> deleteTask({required String id});

  Future<Task> toggleChecklistItem({
    required String taskId,
    required String itemId,
  });
}
