import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/empty_state_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task_params.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/widgets/task_card.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/widgets/task_checklist_widget.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/widgets/task_filters_bar.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/widgets/task_priority_chip.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/widgets/task_search_bar.dart';
import 'package:personal_os_dashboard/features/tasks/presentation/widgets/task_status_chip.dart';

/// Tasks list and management screen.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key, this.initialProjectId});

  final String? initialProjectId;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialProjectId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(tasksListProvider.notifier)
            .setProjectFilter(widget.initialProjectId);
        ref.read(tasksFilterProvider.notifier).state =
            TaskFilter(projectId: widget.initialProjectId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksListProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final projectId = widget.initialProjectId ??
              ref.read(tasksFilterProvider).projectId;
          final path = projectId != null
              ? '${RouteConstants.taskCreate}?projectId=$projectId'
              : RouteConstants.taskCreate;
          context.push(path);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: tasksAsync.when(
        loading: () => const LoadingView(message: 'Loading tasks...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(tasksListProvider.notifier).refresh(),
        ),
        data: (_) => RefreshIndicator(
          onRefresh: () => ref.read(tasksListProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    isDesktop ? AppSpacing.xl : AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isDesktop)
                        Text(
                          'Tasks',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      if (!isDesktop) const SizedBox(height: AppSpacing.lg),
                      const TaskSearchBar(),
                      const SizedBox(height: AppSpacing.md),
                      const TaskFiltersBar(),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${filteredTasks.length} task${filteredTasks.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (filteredTasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    title: 'No tasks found',
                    message: ref.watch(tasksSearchQueryProvider).isNotEmpty ||
                            ref.watch(tasksFilterProvider).hasActiveFilters
                        ? 'Try adjusting your search or filters.'
                        : 'Create your first task to start tracking work.',
                    icon: Icons.task_alt_outlined,
                    actionLabel: 'Add Task',
                    onAction: () => context.push(RouteConstants.taskCreate),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = filteredTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () => _showTaskDetail(context, task),
                          onEdit: () => context.push(
                            RouteConstants.taskEdit.replaceFirst(':id', task.id),
                          ),
                          onComplete: () => ref
                              .read(tasksListProvider.notifier)
                              .completeTask(task.id),
                          onDelete: () => _confirmDelete(context, ref, task),
                        );
                      },
                      childCount: filteredTasks.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetail(BuildContext context, Task task) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _TaskDetailSheet(task: task),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('This will permanently delete "${task.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(taskFormControllerProvider.notifier).deleteTask(
            task.id,
            projectId: task.projectId,
          );
    }
  }
}

class _TaskDetailSheet extends StatelessWidget {
  const _TaskDetailSheet({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            task.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              task.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              TaskStatusChip(status: task.status),
              TaskPriorityChip(priority: task.priority),
              if (task.projectName != null)
                Chip(label: Text(task.projectName!)),
            ],
          ),
          if (task.dueDate != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(app_date.DateUtils.formatDisplayDate(task.dueDate!)),
              ],
            ),
          ],
          if (task.reminderAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.notifications_outlined, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(app_date.DateUtils.formatDisplayDateTime(task.reminderAt!)),
              ],
            ),
          ],
          if (task.checklist.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            TaskChecklistWidget(
              items: task.checklist,
              readOnly: true,
              onChanged: (_) {},
            ),
          ],
          if (task.subtasks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            TaskSubtasksList(subtasks: task.subtasks),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(RouteConstants.taskEdit.replaceFirst(':id', task.id));
            },
            child: const Text('Edit Task'),
          ),
        ],
      ),
    );
  }
}
