import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';

class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({required this.status, super.key});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      ProjectStatus.planning => (AppColors.infoLight, AppColors.infoDark),
      ProjectStatus.active => (AppColors.successLight, AppColors.successDark),
      ProjectStatus.onHold => (AppColors.warningLight, AppColors.warningDark),
      ProjectStatus.completed =>
        (AppColors.secondaryContainer, AppColors.onSecondaryContainer),
      ProjectStatus.cancelled => (AppColors.errorLight, AppColors.errorDark),
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
