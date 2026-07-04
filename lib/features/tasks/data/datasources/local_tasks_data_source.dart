import 'package:personal_os_dashboard/features/tasks/data/datasources/tasks_data_source.dart';
import 'package:personal_os_dashboard/features/tasks/data/models/task_model.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';

final class LocalTasksDataSource implements TasksDataSource {
  final Map<String, TaskModel> _tasks = {};

  LocalTasksDataSource() {
    _seed();
  }

  void _seed() {
    const userId = 'local-user';
    final now = DateTime.now();

    final task1 = TaskModel(
      id: 'task-local-1',
      userId: userId,
      projectId: 'proj-local-1',
      parentTaskId: null,
      title: 'Implement auth module',
      description: 'Build complete authentication with Supabase and Riverpod.',
      status: 'completed',
      priority: 'high',
      dueDate: now.subtract(const Duration(days: 10)),
      reminderAt: null,
      checklist: const [
        ChecklistItem(id: 'cl-1', title: 'Login screen', isCompleted: true),
        ChecklistItem(id: 'cl-2', title: 'Signup screen', isCompleted: true),
        ChecklistItem(id: 'cl-3', title: 'Session management', isCompleted: true),
      ],
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 5)),
      projectName: 'Personal OS Dashboard',
    );

    final task2 = TaskModel(
      id: 'task-local-2',
      userId: userId,
      projectId: 'proj-local-1',
      parentTaskId: null,
      title: 'Build task management module',
      description: 'CRUD tasks with checklist, subtasks, and project linking.',
      status: 'in_progress',
      priority: 'high',
      dueDate: now.add(const Duration(days: 7)),
      reminderAt: now.add(const Duration(days: 6)),
      checklist: const [
        ChecklistItem(id: 'cl-4', title: 'Domain layer', isCompleted: true),
        ChecklistItem(id: 'cl-5', title: 'UI screens', isCompleted: false),
        ChecklistItem(id: 'cl-6', title: 'Supabase integration', isCompleted: false),
      ],
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      projectName: 'Personal OS Dashboard',
    );

    final task3 = TaskModel(
      id: 'task-local-3',
      userId: userId,
      projectId: null,
      parentTaskId: null,
      title: 'Weekly review',
      description: 'Review goals and plan next week priorities.',
      status: 'pending',
      priority: 'medium',
      dueDate: now.add(const Duration(days: 2)),
      reminderAt: now.add(const Duration(days: 1, hours: 9)),
      checklist: const [],
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 12)),
    );

    _tasks[task1.id] = task1;
    _tasks[task2.id] = task2;
    _tasks[task3.id] = task3;

    _tasks['task-sub-1'] = TaskModel(
      id: 'task-sub-1',
      userId: userId,
      projectId: 'proj-local-1',
      parentTaskId: task2.id,
      title: 'Write unit tests',
      description: '',
      status: 'pending',
      priority: 'medium',
      dueDate: now.add(const Duration(days: 5)),
      reminderAt: null,
      checklist: const [],
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(days: 3)),
    );
  }

  List<TaskModel> _topLevel(String userId, {String? projectId}) {
    return _tasks.values
        .where(
          (t) =>
              (t.userId == userId || t.userId == 'local-user') &&
              t.parentTaskId == null &&
              (projectId == null || t.projectId == projectId),
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<TaskModel> _subtasks(String parentId) {
    return _tasks.values.where((t) => t.parentTaskId == parentId).toList();
  }

  @override
  Future<List<TaskModel>> getTasks({
    required String userId,
    String? projectId,
  }) async =>
      _topLevel(userId, projectId: projectId);

  @override
  Future<TaskModel> getTaskById({required String id}) async {
    final task = _tasks[id];
    if (task == null) throw StateError('Task not found');
    return task;
  }

  @override
  Future<TaskModel> createTask({
    required String userId,
    required CreateTaskParams params,
  }) async {
    final now = DateTime.now();
    final id = 'task-local-${now.microsecondsSinceEpoch}';
    final task = TaskModel(
      id: id,
      userId: userId,
      projectId: params.projectId,
      parentTaskId: params.parentTaskId,
      title: params.title.trim(),
      description: params.description.trim(),
      status: params.status,
      priority: params.priority,
      dueDate: params.dueDate,
      reminderAt: params.reminderAt,
      checklist: params.checklist,
      createdAt: now,
      updatedAt: now,
    );
    _tasks[id] = task;

    for (final title in params.subtasks) {
      if (title.trim().isEmpty) continue;
      final subId = 'task-sub-${DateTime.now().microsecondsSinceEpoch}';
      _tasks[subId] = TaskModel(
        id: subId,
        userId: userId,
        projectId: params.projectId,
        parentTaskId: id,
        title: title.trim(),
        description: '',
        status: 'pending',
        priority: params.priority,
        dueDate: null,
        reminderAt: null,
        checklist: const [],
        createdAt: now,
        updatedAt: now,
      );
    }

    return task;
  }

  @override
  Future<TaskModel> updateTask({
    required String userId,
    required UpdateTaskParams params,
  }) async {
    final existing = await getTaskById(id: params.id);
    final updated = TaskModel(
      id: existing.id,
      userId: userId,
      projectId: params.clearProjectId ? null : params.projectId,
      parentTaskId: existing.parentTaskId,
      title: params.title.trim(),
      description: params.description.trim(),
      status: params.status,
      priority: params.priority,
      dueDate: params.clearDueDate ? null : params.dueDate,
      reminderAt: params.clearReminder ? null : params.reminderAt,
      checklist: params.checklist,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      projectName: existing.projectName,
    );
    _tasks[updated.id] = updated;

    _tasks.removeWhere((_, t) => t.parentTaskId == params.id);
    for (final title in params.subtasks) {
      if (title.trim().isEmpty) continue;
      final subId = 'task-sub-${DateTime.now().microsecondsSinceEpoch}';
      _tasks[subId] = TaskModel(
        id: subId,
        userId: userId,
        projectId: updated.projectId,
        parentTaskId: params.id,
        title: title.trim(),
        description: '',
        status: 'pending',
        priority: params.priority,
        dueDate: null,
        reminderAt: null,
        checklist: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return updated;
  }

  @override
  Future<TaskModel> completeTask({required String id}) async {
    final existing = await getTaskById(id: id);
    final updated = TaskModel(
      id: existing.id,
      userId: existing.userId,
      projectId: existing.projectId,
      parentTaskId: existing.parentTaskId,
      title: existing.title,
      description: existing.description,
      status: 'completed',
      priority: existing.priority,
      dueDate: existing.dueDate,
      reminderAt: existing.reminderAt,
      checklist: existing.checklist,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      projectName: existing.projectName,
    );
    _tasks[id] = updated;
    return updated;
  }

  @override
  Future<void> deleteTask({required String id}) async {
    _tasks.removeWhere((_, t) => t.parentTaskId == id || t.id == id);
  }

  @override
  Future<TaskModel> toggleChecklistItem({
    required String taskId,
    required String itemId,
  }) async {
    final existing = await getTaskById(id: taskId);
    final checklist = existing.checklist
        .map(
          (item) => item.id == itemId
              ? item.copyWith(isCompleted: !item.isCompleted)
              : item,
        )
        .toList();
    final updated = TaskModel(
      id: existing.id,
      userId: existing.userId,
      projectId: existing.projectId,
      parentTaskId: existing.parentTaskId,
      title: existing.title,
      description: existing.description,
      status: existing.status,
      priority: existing.priority,
      dueDate: existing.dueDate,
      reminderAt: existing.reminderAt,
      checklist: checklist,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      projectName: existing.projectName,
    );
    _tasks[taskId] = updated;
    return updated;
  }

  List<TaskModel> subtasksFor(String parentId) => _subtasks(parentId);
}
