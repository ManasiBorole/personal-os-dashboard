import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/projects/presentation/providers/projects_provider.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/providers/tasks_provider.dart';

/// Filter and sort controls for the tasks list.
class TaskFiltersBar extends ConsumerWidget {
  const TaskFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(tasksFilterProvider);
    final sort = ref.watch(tasksSortProvider);
    final projects = ref.watch(projectsListProvider).maybeWhen(
          data: (value) => value,
          orElse: () => const <Project>[],
        );

    String? projectLabel;
    if (filter.projectId != null) {
      projectLabel = projects
          .where((p) => p.id == filter.projectId)
          .map((p) => p.name)
          .firstOrNull;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'Status',
                value: filter.status?.label,
                onTap: () => _pickStatus(context, ref, filter.status),
                onClear: filter.status != null
                    ? () => ref.read(tasksFilterProvider.notifier).state =
                        filter.copyWith(clearStatus: true)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Priority',
                value: filter.priority?.label,
                onTap: () => _pickPriority(context, ref, filter.priority),
                onClear: filter.priority != null
                    ? () => ref.read(tasksFilterProvider.notifier).state =
                        filter.copyWith(clearPriority: true)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Project',
                value: projectLabel,
                onTap: () => _pickProject(context, ref, filter.projectId, projects),
                onClear: filter.projectId != null
                    ? () => ref.read(tasksFilterProvider.notifier).state =
                        filter.copyWith(clearProjectId: true)
                    : null,
              ),
              if (filter.hasActiveFilters) ...[
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: () => ref.read(tasksFilterProvider.notifier).state =
                      TaskFilter.empty,
                  child: const Text('Clear all'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: DropdownButton<TaskSortOption>(
            value: sort,
            underline: const SizedBox.shrink(),
            items: [
              for (final option in TaskSortOption.values)
                DropdownMenuItem(
                  value: option,
                  child: Text(option.label),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(tasksSortProvider.notifier).state = value;
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickStatus(
    BuildContext context,
    WidgetRef ref,
    TaskStatus? current,
  ) async {
    final selected = await showModalBottomSheet<TaskStatus>(
      context: context,
      builder: (context) => _PickerSheet<TaskStatus>(
        title: 'Filter by status',
        options: TaskStatus.values,
        labelBuilder: (value) => value.label,
        selected: current,
      ),
    );

    if (selected != null) {
      ref.read(tasksFilterProvider.notifier).state =
          ref.read(tasksFilterProvider).copyWith(status: selected);
    }
  }

  Future<void> _pickPriority(
    BuildContext context,
    WidgetRef ref,
    TaskPriority? current,
  ) async {
    final selected = await showModalBottomSheet<TaskPriority>(
      context: context,
      builder: (context) => _PickerSheet<TaskPriority>(
        title: 'Filter by priority',
        options: TaskPriority.values,
        labelBuilder: (value) => value.label,
        selected: current,
      ),
    );

    if (selected != null) {
      ref.read(tasksFilterProvider.notifier).state =
          ref.read(tasksFilterProvider).copyWith(priority: selected);
    }
  }

  Future<void> _pickProject(
    BuildContext context,
    WidgetRef ref,
    String? current,
    List<Project> projects,
  ) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Filter by project',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              title: const Text('No project'),
              trailing: current == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop('__none__'),
            ),
            for (final project in projects)
              ListTile(
                title: Text(project.name),
                trailing: current == project.id ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(project.id),
              ),
          ],
        ),
      ),
    );

    if (selected != null) {
      ref.read(tasksFilterProvider.notifier).state =
          ref.read(tasksFilterProvider).copyWith(
                projectId: selected == '__none__' ? null : selected,
                clearProjectId: selected == '__none__',
              );
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
    this.value,
    this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isActive = value != null;

    return FilterChip(
      label: Text(value ?? label),
      selected: isActive,
      onSelected: (_) => onTap(),
      deleteIcon: onClear != null ? const Icon(Icons.close, size: 16) : null,
      onDeleted: onClear,
    );
  }
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.labelBuilder,
    this.selected,
  });

  final String title;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final option in options)
            ListTile(
              title: Text(labelBuilder(option)),
              trailing: option == selected ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    );
  }
}
