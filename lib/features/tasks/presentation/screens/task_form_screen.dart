import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/utils/validators.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/core/widgets/inputs/app_text_field.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/projects/presentation/providers/projects_provider.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_form_state.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/widgets/task_checklist_widget.dart';

/// Create or edit task form screen.
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({
    super.key,
    this.taskId,
    this.initialProjectId,
  });

  final String? taskId;
  final String? initialProjectId;

  bool get isEditing => taskId != null;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();

  TaskStatus _status = TaskStatus.pending;
  TaskPriority _priority = TaskPriority.medium;
  String? _projectId;
  DateTime? _dueDate;
  DateTime? _reminderAt;
  List<ChecklistItem> _checklist = [];
  List<String> _subtasks = [];
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _populateFromTask(Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _status = task.status;
    _priority = task.priority;
    _projectId = task.projectId;
    _dueDate = task.dueDate;
    _reminderAt = task.reminderAt;
    _checklist = List<ChecklistItem>.from(task.checklist);
    _subtasks = task.subtasks.map((s) => s.title).toList();
    _initialized = true;
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      initialDate: _dueDate ?? now,
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDate: _reminderAt ?? _dueDate ?? now,
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? now),
    );

    if (time != null) {
      setState(() {
        _reminderAt = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _addSubtask() {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _subtasks = [..._subtasks, title];
      _subtaskController.clear();
    });
  }

  void _removeSubtask(int index) {
    setState(() => _subtasks = List<String>.from(_subtasks)..removeAt(index));
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    ref.read(taskFormControllerProvider.notifier).clearStatus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(taskFormControllerProvider.notifier);
    final success = widget.isEditing
        ? await controller.updateTask(
            UpdateTaskParams(
              id: widget.taskId!,
              title: _titleController.text,
              description: _descriptionController.text,
              status: _status.storageValue,
              priority: _priority.name,
              projectId: _projectId,
              dueDate: _dueDate,
              reminderAt: _reminderAt,
              checklist: _checklist,
              subtasks: _subtasks,
              clearProjectId: _projectId == null,
              clearDueDate: _dueDate == null,
              clearReminder: _reminderAt == null,
            ),
          )
        : await controller.createTask(
            CreateTaskParams(
              title: _titleController.text,
              description: _descriptionController.text,
              status: _status.storageValue,
              priority: _priority.name,
              projectId: _projectId ?? widget.initialProjectId,
              parentTaskId: null,
              dueDate: _dueDate,
              reminderAt: _reminderAt,
              checklist: _checklist,
              subtasks: _subtasks,
            ),
          );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized && widget.initialProjectId != null) {
      _projectId = widget.initialProjectId;
      _initialized = true;
    }

    if (widget.isEditing) {
      final taskAsync = ref.watch(taskDetailProvider(widget.taskId!));

      return taskAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Task')),
          body: const LoadingView(message: 'Loading task...'),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Edit Task')),
          body: ErrorView(message: error.toString()),
        ),
        data: (task) {
          if (!_initialized || _titleController.text.isEmpty) {
            _populateFromTask(task);
          }
          return _buildScaffold(context);
        },
      );
    }

    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    final formState = ref.watch(taskFormControllerProvider);
    final projects = ref.watch(projectsListProvider).maybeWhen(
          data: (value) => value,
          orElse: () => const <Project>[],
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (formState is TaskFormError)
                    _MessageBanner(
                      message: formState.message,
                      isError: true,
                    ),
                  if (formState is TaskFormSuccess)
                    _MessageBanner(
                      message: formState.message ?? 'Saved',
                      isError: false,
                    ),
                  AppTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'What needs to be done?',
                    enabled: !formState.isLoading,
                    validator: (value) => Validators.combine([
                      (v) => Validators.required(v, fieldName: 'Title'),
                      (v) => Validators.maxLength(
                            v,
                            AppConstants.maxTitleLength,
                            fieldName: 'Title',
                          ),
                    ])(value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Add details, context, or notes',
                    enabled: !formState.isLoading,
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<TaskStatus>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      for (final status in TaskStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                    ],
                    onChanged: formState.isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<TaskPriority>(
                    value: _priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: [
                      for (final priority in TaskPriority.values)
                        DropdownMenuItem(
                          value: priority,
                          child: Text(priority.label),
                        ),
                    ],
                    onChanged: formState.isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _priority = value);
                            }
                          },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String?>(
                    value: _projectId,
                    decoration: const InputDecoration(labelText: 'Project'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No project'),
                      ),
                      for (final project in projects)
                        DropdownMenuItem(
                          value: project.id,
                          child: Text(project.name),
                        ),
                    ],
                    onChanged: formState.isLoading
                        ? null
                        : (value) => setState(() => _projectId = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Deadline'),
                    subtitle: Text(
                      _dueDate != null
                          ? app_date.DateUtils.formatDisplayDate(_dueDate!)
                          : 'No deadline set',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_dueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: formState.isLoading
                                ? null
                                : () => setState(() => _dueDate = null),
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today_outlined),
                          onPressed:
                              formState.isLoading ? null : _pickDueDate,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reminder'),
                    subtitle: Text(
                      _reminderAt != null
                          ? app_date.DateUtils.formatDisplayDateTime(
                              _reminderAt!,
                            )
                          : 'No reminder set',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_reminderAt != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: formState.isLoading
                                ? null
                                : () => setState(() => _reminderAt = null),
                          ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed:
                              formState.isLoading ? null : _pickReminder,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TaskChecklistWidget(
                    items: _checklist,
                    onChanged: formState.isLoading
                        ? (_) {}
                        : (items) => setState(() => _checklist = items),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Subtasks', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  for (var i = 0; i < _subtasks.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_subtasks[i]),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: formState.isLoading
                            ? null
                            : () => _removeSubtask(i),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subtaskController,
                          enabled: !formState.isLoading,
                          decoration: const InputDecoration(
                            hintText: 'Add subtask',
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addSubtask(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: formState.isLoading ? null : _addSubtask,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: widget.isEditing ? 'Save Changes' : 'Create Task',
                    isLoading: formState.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isError
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
      ),
      child: Text(message),
    );
  }
}
