import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/dashboard_card.dart';

/// Task counts grouped by status.
class TaskSummaryCard extends StatelessWidget {
  const TaskSummaryCard({
    required this.summary,
    super.key,
  });

  final TaskSummary summary;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Task Summary',
      subtitle: '${summary.total} total tasks',
      child: Column(
        children: [
          _TaskProgressBar(
            completed: summary.completed,
            total: summary.total,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _TaskStat(
                label: 'Completed',
                value: summary.completed,
                color: AppColors.success,
              ),
              _TaskStat(
                label: 'In Progress',
                value: summary.inProgress,
                color: AppColors.info,
              ),
              _TaskStat(
                label: 'Due Today',
                value: summary.dueToday,
                color: AppColors.accent,
              ),
              _TaskStat(
                label: 'Overdue',
                value: summary.overdue,
                color: AppColors.error,
              ),
              _TaskStat(
                label: 'High Priority',
                value: summary.highPriority,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskProgressBar extends StatelessWidget {
  const _TaskProgressBar({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completion',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

class _TaskStat extends StatelessWidget {
  const _TaskStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
