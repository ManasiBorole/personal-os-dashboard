import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/tasks/domain/entities/task.dart';

/// Colored status badge for a task.
class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({
    required this.status,
    super.key,
  });

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      TaskStatus.pending => (AppColors.warningLight, AppColors.warningDark),
      TaskStatus.inProgress => (AppColors.infoLight, AppColors.infoDark),
      TaskStatus.completed => (AppColors.successLight, AppColors.successDark),
      TaskStatus.cancelled => (AppColors.errorLight, AppColors.errorDark),
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
