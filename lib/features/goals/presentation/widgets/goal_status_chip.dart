import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/goals/domain/entities/goal.dart';

/// Colored status badge for a goal.
class GoalStatusChip extends StatelessWidget {
  const GoalStatusChip({
    required this.status,
    super.key,
  });

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      GoalStatus.active => (AppColors.infoLight, AppColors.infoDark),
      GoalStatus.completed => (AppColors.successLight, AppColors.successDark),
      GoalStatus.paused => (AppColors.warningLight, AppColors.warningDark),
      GoalStatus.cancelled => (AppColors.errorLight, AppColors.errorDark),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.$2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
