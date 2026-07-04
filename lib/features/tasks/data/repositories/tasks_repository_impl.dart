import 'package:personal_os_dashboard/features/tasks/data/datasources/local_tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/data/datasources/tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/data/models/task_model.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';
import 'package:personal_os_dashboard/features/tasks/domain/repositories/tasks_repository.dart';

final class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl(this._dataSource);

  final TasksDataSource _dataSource;

  @override
  Future<List<Task>> getTasks({
    required String userId,
    String? projectId,
  }) async {
    final models = await _dataSource.getTasks(
      userId: userId,
      projectId: projectId,
    );
    return Future.wait(models.map(_toEntityWithSubtasks));
  }

  @override
  Future<Task> getTaskById({required String id}) async {
    final model = await _dataSource.getTaskById(id: id);
    return _toEntityWithSubtasks(model);
  }

  Future<Task> _toEntityWithSubtasks(TaskModel model) async {
    List<Task> subtasks = const [];
    if (_dataSource is LocalTasksDataSource) {
      subtasks = _dataSource
          .subtasksFor(model.id)
          .map((m) => m.toEntity())
          .toList();
    } else {
      final all = await _dataSource.getTasks(userId: model.userId);
      subtasks = all
          .where((t) => t.parentTaskId == model.id)
          .map((m) => m.toEntity())
          .toList();
    }
    return model.toEntity(subtasks: subtasks);
  }

  @override
  Future<Task> createTask({
    required String userId,
    required CreateTaskParams params,
  }) async {
    final model = await _dataSource.createTask(userId: userId, params: params);
    return _toEntityWithSubtasks(model);
  }

  @override
  Future<Task> updateTask({
    required String userId,
    required UpdateTaskParams params,
  }) async {
    final model = await _dataSource.updateTask(userId: userId, params: params);
    return _toEntityWithSubtasks(model);
  }

  @override
  Future<Task> completeTask({required String id}) async {
    final model = await _dataSource.completeTask(id: id);
    return _toEntityWithSubtasks(model);
  }

  @override
  Future<void> deleteTask({required String id}) async {
    await _dataSource.deleteTask(id: id);
  }

  @override
  Future<Task> toggleChecklistItem({
    required String taskId,
    required String itemId,
  }) async {
    final model = await _dataSource.toggleChecklistItem(
      taskId: taskId,
      itemId: itemId,
    );
    return _toEntityWithSubtasks(model);
  }
}

final class UnconfiguredTasksRepository implements TasksRepository {
  UnconfiguredTasksRepository()
      : _delegate = TasksRepositoryImpl(LocalTasksDataSource());

  final TasksRepositoryImpl _delegate;

  @override
  Future<List<Task>> getTasks({
    required String userId,
    String? projectId,
  }) =>
      _delegate.getTasks(userId: userId, projectId: projectId);

  @override
  Future<Task> getTaskById({required String id}) =>
      _delegate.getTaskById(id: id);

  @override
  Future<Task> createTask({
    required String userId,
    required CreateTaskParams params,
  }) =>
      _delegate.createTask(userId: userId, params: params);

  @override
  Future<Task> updateTask({
    required String userId,
    required UpdateTaskParams params,
  }) =>
      _delegate.updateTask(userId: userId, params: params);

  @override
  Future<Task> completeTask({required String id}) =>
      _delegate.completeTask(id: id);

  @override
  Future<void> deleteTask({required String id}) =>
      _delegate.deleteTask(id: id);

  @override
  Future<Task> toggleChecklistItem({
    required String taskId,
    required String itemId,
  }) =>
      _delegate.toggleChecklistItem(taskId: taskId, itemId: itemId);
}

TasksRepository createTasksRepository({
  required bool isSupabaseReady,
  required TasksDataSource remoteDataSource,
}) {
  if (isSupabaseReady) {
    return TasksRepositoryImpl(remoteDataSource);
  }
  return UnconfiguredTasksRepository();
}
