import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';

/// Colored badge for calendar event type.
class CalendarEventTypeChip extends StatelessWidget {
  const CalendarEventTypeChip({
    required this.eventType,
    super.key,
  });

  final CalendarEventType eventType;

  @override
  Widget build(BuildContext context) {
    final colors = switch (eventType) {
      CalendarEventType.task => (AppColors.infoLight, AppColors.infoDark),
      CalendarEventType.meeting => (AppColors.accent.withValues(alpha: 0.2), AppColors.accent),
      CalendarEventType.birthday => (AppColors.warningLight, AppColors.warningDark),
      CalendarEventType.reminder => (AppColors.successLight, AppColors.successDark),
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
        eventType.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.$2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

Color eventTypeColor(CalendarEventType type) {
  return switch (type) {
    CalendarEventType.task => AppColors.info,
    CalendarEventType.meeting => AppColors.accent,
    CalendarEventType.birthday => AppColors.warningDark,
    CalendarEventType.reminder => AppColors.success,
  };
}
