import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';

class MeetingStatusChip extends StatelessWidget {
  const MeetingStatusChip({required this.status, super.key});

  final MeetingStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      MeetingStatus.scheduled => (AppColors.infoLight, AppColors.infoDark),
      MeetingStatus.completed => (AppColors.successLight, AppColors.successDark),
      MeetingStatus.cancelled => (AppColors.errorLight, AppColors.errorDark),
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
