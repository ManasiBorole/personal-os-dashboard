import 'package:flutter/material.dart' hide DateUtils;

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/dashboard_card.dart';

/// Upcoming meetings timeline.
class UpcomingMeetingsCard extends StatelessWidget {
  const UpcomingMeetingsCard({
    required this.meetings,
    super.key,
  });

  final List<UpcomingMeetingItem> meetings;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Upcoming Meetings',
      subtitle: 'Next ${meetings.length} scheduled',
      child: meetings.isEmpty
          ? const Text('No meetings scheduled.')
          : Column(
              children: [
                for (var i = 0; i < meetings.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  _MeetingTile(meeting: meetings[i]),
                ],
              ],
            ),
    );
  }
}

class _MeetingTile extends StatelessWidget {
  const _MeetingTile({required this.meeting});

  final UpcomingMeetingItem meeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Column(
              children: [
                Text(
                  DateUtils.formatTime(meeting.startTime),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${meeting.durationMinutes}m',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    if (meeting.location != null) ...[
                      Icon(
                        Icons.videocam_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          meeting.location!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      '${meeting.attendeeCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
