import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/notifications/data/services/notification_coordinator.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/notifications/domain/usecases/notification_usecases.dart';

enum NotificationFilter {
  all('All'),
  unread('Unread'),
  taskReminder('Tasks'),
  meetingReminder('Meetings'),
  goalDeadline('Goals'),
  birthdayReminder('Birthdays');

  const NotificationFilter(this.label);

  final String label;
}

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(ref.watch(notificationsRepositoryProvider));
});

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
  return MarkNotificationReadUseCase(ref.watch(notificationsRepositoryProvider));
});

final markAllNotificationsReadUseCaseProvider =
    Provider<MarkAllNotificationsReadUseCase>((ref) {
  return MarkAllNotificationsReadUseCase(
    ref.watch(notificationsRepositoryProvider),
  );
});

final deleteNotificationUseCaseProvider =
    Provider<DeleteNotificationUseCase>((ref) {
  return DeleteNotificationUseCase(ref.watch(notificationsRepositoryProvider));
});

final getUnreadNotificationCountUseCaseProvider =
    Provider<GetUnreadNotificationCountUseCase>((ref) {
  return GetUnreadNotificationCountUseCase(
    ref.watch(notificationsRepositoryProvider),
  );
});

final notificationCoordinatorProvider = Provider<NotificationCoordinator>((ref) {
  return sl<NotificationCoordinator>();
});

final notificationFilterProvider =
    StateProvider<NotificationFilter>((ref) => NotificationFilter.all);

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsListController, List<AppNotification>>(
  NotificationsListController.new,
);

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notificationsListProvider);
  final userId = ref.watch(currentUserProvider)?.id ?? 'local-user';
  final result =
      await ref.read(getUnreadNotificationCountUseCaseProvider).call(userId);
  return result.when(
    success: (count) => count,
    onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
  );
});

final reminderSyncProvider = FutureProvider<void>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id ?? 'local-user';
  await ref.read(notificationCoordinatorProvider).syncReminders(userId: userId);
  ref.invalidate(notificationsListProvider);
  ref.invalidate(unreadNotificationCountProvider);
});

class NotificationsListController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    ref.watch(reminderSyncProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
      await ref.read(notificationCoordinatorProvider).syncReminders(
            userId: userId,
          );
      return _load();
    });
  }

  Future<void> markAsRead(String id) async {
    final result =
        await ref.read(markNotificationReadUseCaseProvider).call(id);
    result.when(
      success: (_) {
        ref.invalidateSelf();
        ref.invalidate(unreadNotificationCountProvider);
      },
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }

  Future<void> markAllRead() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result =
        await ref.read(markAllNotificationsReadUseCaseProvider).call(userId);
    result.when(
      success: (_) {
        ref.invalidateSelf();
        ref.invalidate(unreadNotificationCountProvider);
      },
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }

  Future<void> deleteNotification(String id) async {
    final result = await ref.read(deleteNotificationUseCaseProvider).call(id);
    result.when(
      success: (_) {
        ref.invalidateSelf();
        ref.invalidate(unreadNotificationCountProvider);
      },
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }

  Future<List<AppNotification>> _load() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final result = await ref.read(getNotificationsUseCaseProvider).call(userId);
    return result.when(
      success: (notifications) => notifications,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}
