import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/presentation/widgets/meeting_status_chip.dart';

class MeetingCard extends StatelessWidget {
  const MeetingCard({
    required this.meeting,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Meeting meeting;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                        case 'delete':
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${app_date.DateUtils.formatDisplayDateTime(meeting.startTime)} · ${meeting.durationMinutes}m',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (meeting.location != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(meeting.location!)),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  MeetingStatusChip(status: meeting.status),
                  Chip(
                    avatar: const Icon(Icons.people_outline, size: 16),
                    label: Text('${meeting.participantCount}'),
                  ),
                  if (meeting.reminderAt != null)
                    const Chip(
                      avatar: Icon(Icons.notifications_outlined, size: 16),
                      label: Text('Reminder'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
