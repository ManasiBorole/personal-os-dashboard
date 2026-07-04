import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/empty_state_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:personal_os_dashboard/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);
    final filter = ref.watch(notificationFilterProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      body: notificationsAsync.when(
        loading: () => const LoadingView(message: 'Loading notifications...'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(notificationsListProvider.notifier).refresh(),
        ),
        data: (notifications) {
          final filtered = _filterNotifications(notifications, filter);

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsListProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      isDesktop ? AppSpacing.xl : AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isDesktop)
                          Text(
                            'Notifications',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        if (!isDesktop) const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                unreadCount.when(
                                  data: (count) =>
                                      '$count unread notification${count == 1 ? '' : 's'}',
                                  loading: () => 'Checking unread...',
                                  error: (_, _) => 'Notifications',
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ),
                            if (unreadCount.maybeWhen(
                              data: (count) => count > 0,
                              orElse: () => false,
                            ))
                              TextButton(
                                onPressed: () => ref
                                    .read(notificationsListProvider.notifier)
                                    .markAllRead(),
                                child: const Text('Mark all read'),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SegmentedButton<NotificationFilter>(
                          segments: [
                            for (final item in NotificationFilter.values)
                              ButtonSegment(
                                value: item,
                                label: Text(item.label),
                              ),
                          ],
                          selected: {filter},
                          onSelectionChanged: (selection) {
                            ref
                                    .read(notificationFilterProvider.notifier)
                                    .state =
                                selection.first;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateView(
                      title: 'No notifications',
                      message: filter == NotificationFilter.all
                          ? 'Reminders for tasks, meetings, goals, and birthdays will appear here.'
                          : 'No ${filter.label.toLowerCase()} notifications yet.',
                      icon: Icons.notifications_none_outlined,
                    ),
                  )
                else
                  SliverList.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = filtered[index];
                      return NotificationTile(
                        notification: notification,
                        onTap: () => _openNotification(context, ref, notification),
                        onDismiss: () => ref
                            .read(notificationsListProvider.notifier)
                            .deleteNotification(notification.id),
                      );
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<AppNotification> _filterNotifications(
    List<AppNotification> notifications,
    NotificationFilter filter,
  ) {
    return switch (filter) {
      NotificationFilter.all => notifications,
      NotificationFilter.unread =>
        notifications.where((n) => !n.isRead).toList(),
      NotificationFilter.taskReminder => notifications
          .where((n) => n.type == NotificationType.taskReminder)
          .toList(),
      NotificationFilter.meetingReminder => notifications
          .where((n) => n.type == NotificationType.meetingReminder)
          .toList(),
      NotificationFilter.goalDeadline => notifications
          .where((n) => n.type == NotificationType.goalDeadline)
          .toList(),
      NotificationFilter.birthdayReminder => notifications
          .where((n) => n.type == NotificationType.birthdayReminder)
          .toList(),
    };
  }

  Future<void> _openNotification(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    if (!notification.isRead) {
      await ref
          .read(notificationsListProvider.notifier)
          .markAsRead(notification.id);
    }

    final route = notification.routePath;
    if (route != null && route.isNotEmpty && context.mounted) {
      await context.push(route);
    }
  }
}
