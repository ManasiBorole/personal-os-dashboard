import 'package:flutter/material.dart' hide DateUtils;

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/dashboard_card.dart';

/// Compact calendar event preview list.
class CalendarPreviewCard extends StatelessWidget {
  const CalendarPreviewCard({
    required this.events,
    super.key,
  });

  final List<CalendarPreviewItem> events;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Calendar Preview',
      subtitle: 'Upcoming events',
      child: events.isEmpty
          ? const Text('No upcoming events.')
          : Column(
              children: [
                for (var i = 0; i < events.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _EventRow(event: events[i], index: i),
                ],
              ],
            ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.index,
  });

  final CalendarPreviewItem event;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.chartColors[index % AppColors.chartColors.length];
    final timeLabel = event.isAllDay
        ? 'All day'
        : '${DateUtils.formatTime(event.startTime)} – ${DateUtils.formatTime(event.endTime)}';

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$timeLabel • ${event.category}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          DateUtils.formatDisplayDate(event.startTime),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
