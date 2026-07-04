import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event.dart';
import 'package:personal_os_dashboard/features/calendar/presentation/widgets/calendar_event_type_chip.dart';

/// Compact event tile for calendar views.
class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile({
    required this.event,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final CalendarEvent event;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = eventTypeColor(event.eventType);

    if (compact) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      event.isAllDay
                          ? 'All day'
                          : '${app_date.DateUtils.formatTime(event.startTime)} – ${app_date.DateUtils.formatTime(event.endTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              CalendarEventTypeChip(eventType: event.eventType),
            ],
          ),
        ),
      ),
    );
  }
}
