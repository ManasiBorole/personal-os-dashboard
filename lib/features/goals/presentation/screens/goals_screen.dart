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
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';
import 'package:personal_os_dashboard/features/goals/presentation/providers/goals_provider.dart';
import 'package:personal_os_dashboard/features/goals/presentation/widgets/goal_card.dart';
import 'package:personal_os_dashboard/features/goals/presentation/widgets/goal_filters_bar.dart';
import 'package:personal_os_dashboard/features/goals/presentation/widgets/goal_progress_tracker.dart';
import 'package:personal_os_dashboard/features/goals/presentation/widgets/goal_search_bar.dart';
import 'package:personal_os_dashboard/features/goals/presentation/widgets/goal_status_chip.dart';

/// Goals list and management screen.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsListProvider);
    final filteredGoals = ref.watch(filteredGoalsProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.goalCreate),
        icon: const Icon(Icons.add),
        label: const Text('Add Goal'),
      ),
      body: goalsAsync.when(
        loading: () => const LoadingView(message: 'Loading goals...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(goalsListProvider.notifier).refresh(),
        ),
        data: (_) => RefreshIndicator(
          onRefresh: () => ref.read(goalsListProvider.notifier).refresh(),
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
                          'Goals',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      if (!isDesktop) const SizedBox(height: AppSpacing.lg),
                      const GoalSearchBar(),
                      const SizedBox(height: AppSpacing.md),
                      const GoalFiltersBar(),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${filteredGoals.length} goal${filteredGoals.length == 1 ? '' : 's'}',
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
              if (filteredGoals.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    title: 'No goals found',
                    message: ref.watch(goalsSearchQueryProvider).isNotEmpty ||
                            ref.watch(goalsFilterProvider).hasActiveFilters
                        ? 'Try adjusting your search or filters.'
                        : 'Create your first goal to start tracking progress.',
                    icon: Icons.flag_outlined,
                    actionLabel: 'Add Goal',
                    onAction: () => context.push(RouteConstants.goalCreate),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final goal = filteredGoals[index];
                        return GoalCard(
                          goal: goal,
                          onTap: () => _showGoalDetail(context, goal),
                          onEdit: () => context.push(
                            RouteConstants.goalEdit.replaceFirst(':id', goal.id),
                          ),
                          onDelete: () => _confirmDelete(context, ref, goal),
                        );
                      },
                      childCount: filteredGoals.length,
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

  void _showGoalDetail(BuildContext context, Goal goal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _GoalDetailSheet(goal: goal),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete goal?'),
        content: Text('This will permanently delete "${goal.title}".'),
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
      await ref.read(goalFormControllerProvider.notifier).deleteGoal(goal.id);
    }
  }
}

class _GoalDetailSheet extends StatelessWidget {
  const _GoalDetailSheet({required this.goal});

  final Goal goal;

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
            goal.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            goal.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              GoalStatusChip(status: goal.status),
              Chip(label: Text(goal.category.label)),
              Chip(label: Text(goal.priority.label)),
            ],
          ),
          if (goal.deadline != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(app_date.DateUtils.formatDisplayDate(goal.deadline!)),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          GoalProgressTracker(progress: goal.progress),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(RouteConstants.goalEdit.replaceFirst(':id', goal.id));
            },
            child: const Text('Edit Goal'),
          ),
        ],
      ),
    );
  }
}
