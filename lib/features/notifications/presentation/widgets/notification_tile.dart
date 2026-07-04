import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _iconForType(notification.type);
    final color = _colorForType(notification.type);
    final timeLabel = DateFormat('MMM d · h:mm a').format(notification.createdAt);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.error.withValues(alpha: 0.12),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: Material(
        color: notification.isRead
            ? theme.cardColor
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.18),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.borderRadiusSm,
                              ),
                            ),
                            child: Text(
                              notification.type.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            timeLabel,
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
          ),
        ),
      ),
    );
  }

  IconData _iconForType(NotificationType type) {
    return switch (type) {
      NotificationType.taskReminder => Icons.task_alt_outlined,
      NotificationType.meetingReminder => Icons.groups_outlined,
      NotificationType.goalDeadline => Icons.flag_outlined,
      NotificationType.birthdayReminder => Icons.cake_outlined,
    };
  }

  Color _colorForType(NotificationType type) {
    return switch (type) {
      NotificationType.taskReminder => AppColors.info,
      NotificationType.meetingReminder => AppColors.primary,
      NotificationType.goalDeadline => AppColors.warning,
      NotificationType.birthdayReminder => AppColors.accent,
    };
  }
}
