import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/features/tasks/data/datasources/tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/data/models/task_model.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';

final class SupabaseTasksDataSource implements TasksDataSource {
  SupabaseTasksDataSource(this._database);

  final DatabaseRemoteDataSource _database;

  @override
  Future<List<TaskModel>> getTasks({
    required String userId,
    String? projectId,
  }) async {
    final filters = <String, dynamic>{'user_id': userId};
    if (projectId != null) filters['project_id'] = projectId;

    final rows = await _database.select(
      table: ApiConstants.tasksTable,
      filters: filters,
      orderBy: 'updated_at',
      ascending: false,
    );

    return rows.map(TaskModel.fromJson).toList();
  }

  @override
  Future<TaskModel> getTaskById({required String id}) async {
    final row = await _database.selectById(
      table: ApiConstants.tasksTable,
      id: id,
    );
    return TaskModel.fromJson(row);
  }

  @override
  Future<TaskModel> createTask({
    required String userId,
    required CreateTaskParams params,
  }) async {
    final parentRow = await _database.insert(
      table: ApiConstants.tasksTable,
      data: {
        'user_id': userId,
        'project_id': params.projectId,
        'parent_task_id': params.parentTaskId,
        'title': params.title.trim(),
        'description': params.description.trim(),
        'status': params.status,
        'priority': params.priority,
        'due_date': params.dueDate?.toIso8601String(),
        'reminder_at': params.reminderAt?.toIso8601String(),
        'checklist': params.checklist
            .map(
              (c) => {
                'id': c.id,
                'title': c.title,
                'is_completed': c.isCompleted,
              },
            )
            .toList(),
      },
    );

    final parent = TaskModel.fromJson(parentRow);

    for (final subtaskTitle in params.subtasks) {
      if (subtaskTitle.trim().isEmpty) continue;
      await _database.insert(
        table: ApiConstants.tasksTable,
        data: {
          'user_id': userId,
          'project_id': params.projectId,
          'parent_task_id': parent.id,
          'title': subtaskTitle.trim(),
          'status': 'pending',
          'priority': params.priority,
        },
      );
    }

    return parent;
  }

  @override
  Future<TaskModel> updateTask({
    required String userId,
    required UpdateTaskParams params,
  }) async {
    final row = await _database.update(
      table: ApiConstants.tasksTable,
      data: {
        'project_id': params.clearProjectId ? null : params.projectId,
        'title': params.title.trim(),
        'description': params.description.trim(),
        'status': params.status,
        'priority': params.priority,
        'due_date': params.clearDueDate ? null : params.dueDate?.toIso8601String(),
        'reminder_at':
            params.clearReminder ? null : params.reminderAt?.toIso8601String(),
        'checklist': params.checklist
            .map(
              (c) => {
                'id': c.id,
                'title': c.title,
                'is_completed': c.isCompleted,
              },
            )
            .toList(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': params.id, 'user_id': userId},
    );

    final existingSubtasks = await _database.select(
      table: ApiConstants.tasksTable,
      filters: {'parent_task_id': params.id},
    );
    for (final sub in existingSubtasks) {
      await _database.delete(
        table: ApiConstants.tasksTable,
        filters: {'id': sub['id']},
      );
    }

    for (final subtaskTitle in params.subtasks) {
      if (subtaskTitle.trim().isEmpty) continue;
      await _database.insert(
        table: ApiConstants.tasksTable,
        data: {
          'user_id': userId,
          'project_id': params.clearProjectId ? null : params.projectId,
          'parent_task_id': params.id,
          'title': subtaskTitle.trim(),
          'status': 'pending',
          'priority': params.priority,
        },
      );
    }

    return TaskModel.fromJson(row);
  }

  @override
  Future<TaskModel> completeTask({required String id}) async {
    final row = await _database.update(
      table: ApiConstants.tasksTable,
      data: {
        'status': 'completed',
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': id},
    );
    return TaskModel.fromJson(row);
  }

  @override
  Future<void> deleteTask({required String id}) async {
    final subtasks = await _database.select(
      table: ApiConstants.tasksTable,
      filters: {'parent_task_id': id},
    );
    for (final sub in subtasks) {
      await _database.delete(
        table: ApiConstants.tasksTable,
        filters: {'id': sub['id']},
      );
    }
    await _database.delete(
      table: ApiConstants.tasksTable,
      filters: {'id': id},
    );
  }

  @override
  Future<TaskModel> toggleChecklistItem({
    required String taskId,
    required String itemId,
  }) async {
    final task = await getTaskById(id: taskId);
    final updatedChecklist = task.checklist
        .map(
          (item) => item.id == itemId
              ? item.copyWith(isCompleted: !item.isCompleted)
              : item,
        )
        .toList();

    final row = await _database.update(
      table: ApiConstants.tasksTable,
      data: {
        'checklist': updatedChecklist
            .map(
              (c) => {
                'id': c.id,
                'title': c.title,
                'is_completed': c.isCompleted,
              },
            )
            .toList(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': taskId},
    );
    return TaskModel.fromJson(row);
  }
}
