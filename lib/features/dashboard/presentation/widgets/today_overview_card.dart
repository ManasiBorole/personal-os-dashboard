import 'package:flutter/material.dart' hide DateUtils;

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';

/// Hero overview card for the current day.
class TodayOverviewCard extends StatelessWidget {
  const TodayOverviewCard({
    required this.overview,
    super.key,
  });

  final TodayOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completionPercent = (overview.taskCompletionRate * 100).round();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overview.greeting,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      DateUtils.formatDisplayDate(overview.date),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              _ScoreBadge(score: overview.productivityScore),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Today\'s focus',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            overview.focusLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _StatChip(
                icon: Icons.task_alt_outlined,
                label: '$completionPercent% tasks',
                value:
                    '${overview.completedTasks}/${overview.totalTasks} done',
              ),
              const SizedBox(width: AppSpacing.md),
              _StatChip(
                icon: Icons.groups_outlined,
                label: 'Meetings',
                value: '${overview.meetingsCount} today',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            '$score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            'Score',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.white, size: AppSpacing.iconMd),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.75),
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
