import 'package:flutter/material.dart' hide DateUtils;

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/dashboard_card.dart';

/// Goal progress list with progress bars.
class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    required this.goals,
    super.key,
  });

  final List<GoalProgressItem> goals;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Goal Progress',
      subtitle: '${goals.length} active goals',
      child: goals.isEmpty
          ? const _EmptyMessage(message: 'No goals yet. Create your first goal.')
          : Column(
              children: [
                for (var i = 0; i < goals.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.lg),
                  _GoalRow(goal: goals[i]),
                ],
              ],
            ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal});

  final GoalProgressItem goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (goal.progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                goal.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$percent%',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppSpacing.borderRadiusSm),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
              ),
              child: Text(
                goal.status,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ),
            if (goal.deadline != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                DateUtils.formatDisplayDate(goal.deadline!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
