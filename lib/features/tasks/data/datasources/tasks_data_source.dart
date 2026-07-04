import 'package:personal_os_dashboard/features/tasks/data/models/task_model.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';

abstract interface class TasksDataSource {
  Future<List<TaskModel>> getTasks({
    required String userId,
    String? projectId,
  });

  Future<TaskModel> getTaskById({required String id});

  Future<TaskModel> createTask({
    required String userId,
    required CreateTaskParams params,
  });

  Future<TaskModel> updateTask({
    required String userId,
    required UpdateTaskParams params,
  });

  Future<TaskModel> completeTask({required String id});

  Future<void> deleteTask({required String id});

  Future<TaskModel> toggleChecklistItem({
    required String taskId,
    required String itemId,
  });
}
