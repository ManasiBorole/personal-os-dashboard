import 'package:personal_os_dashboard/features/notifications/data/datasources/local_notifications_data_source.dart';
import 'package:personal_os_dashboard/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification_params.dart';
import 'package:personal_os_dashboard/features/notifications/domain/repositories/notifications_repository.dart';

final class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._dataSource);

  final NotificationsDataSource _dataSource;

  @override
  Future<List<AppNotification>> getNotifications({
    required String userId,
  }) async {
    final models = await _dataSource.getNotifications(userId: userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AppNotification> createNotification({
    required String userId,
    required CreateNotificationParams params,
  }) async {
    final model = await _dataSource.createNotification(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<AppNotification> markAsRead({required String id}) async {
    final model = await _dataSource.markAsRead(id: id);
    return model.toEntity();
  }

  @override
  Future<void> markAllAsRead({required String userId}) async {
    await _dataSource.markAllAsRead(userId: userId);
  }

  @override
  Future<void> deleteNotification({required String id}) async {
    await _dataSource.deleteNotification(id: id);
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    final notifications = await getNotifications(userId: userId);
    return notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<bool> existsByDedupeKey({
    required String userId,
    required String dedupeKey,
  }) async {
    return _dataSource.existsByDedupeKey(
      userId: userId,
      dedupeKey: dedupeKey,
    );
  }
}

final class UnconfiguredNotificationsRepository implements NotificationsRepository {
  UnconfiguredNotificationsRepository()
      : _delegate = NotificationsRepositoryImpl(LocalNotificationsDataSource());

  final NotificationsRepositoryImpl _delegate;

  @override
  Future<List<AppNotification>> getNotifications({required String userId}) =>
      _delegate.getNotifications(userId: userId);

  @override
  Future<AppNotification> createNotification({
    required String userId,
    required CreateNotificationParams params,
  }) =>
      _delegate.createNotification(userId: userId, params: params);

  @override
  Future<AppNotification> markAsRead({required String id}) =>
      _delegate.markAsRead(id: id);

  @override
  Future<void> markAllAsRead({required String userId}) =>
      _delegate.markAllAsRead(userId: userId);

  @override
  Future<void> deleteNotification({required String id}) =>
      _delegate.deleteNotification(id: id);

  @override
  Future<int> getUnreadCount({required String userId}) =>
      _delegate.getUnreadCount(userId: userId);

  @override
  Future<bool> existsByDedupeKey({
    required String userId,
    required String dedupeKey,
  }) =>
      _delegate.existsByDedupeKey(userId: userId, dedupeKey: dedupeKey);
}

NotificationsRepository createNotificationsRepository({
  required bool isSupabaseReady,
  required NotificationsDataSource remoteDataSource,
}) {
  if (isSupabaseReady) {
    return NotificationsRepositoryImpl(remoteDataSource);
  }
  return UnconfiguredNotificationsRepository();
}
