import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:personal_os_dashboard/features/notifications/data/models/notification_model.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification_params.dart';

final class SupabaseNotificationsDataSource implements NotificationsDataSource {
  SupabaseNotificationsDataSource(this._database);

  final DatabaseRemoteDataSource _database;

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
  }) async {
    final rows = await _database.select(
      table: ApiConstants.notificationsTable,
      filters: {'user_id': userId},
      orderBy: 'created_at',
      ascending: false,
    );
    return rows.map(NotificationModel.fromJson).toList();
  }

  @override
  Future<NotificationModel> createNotification({
    required String userId,
    required CreateNotificationParams params,
  }) async {
    final model = NotificationModel.fromParams(
      id: 'pending',
      userId: userId,
      params: params,
    );
    final row = await _database.insert(
      table: ApiConstants.notificationsTable,
      data: model.toInsertJson(userId),
    );
    return NotificationModel.fromJson(row);
  }

  @override
  Future<NotificationModel> markAsRead({required String id}) async {
    final row = await _database.update(
      table: ApiConstants.notificationsTable,
      data: {'is_read': true},
      filters: {'id': id},
    );
    return NotificationModel.fromJson(row);
  }

  @override
  Future<void> markAllAsRead({required String userId}) async {
    await _database.update(
      table: ApiConstants.notificationsTable,
      data: {'is_read': true},
      filters: {'user_id': userId},
    );
  }

  @override
  Future<void> deleteNotification({required String id}) async {
    await _database.delete(
      table: ApiConstants.notificationsTable,
      filters: {'id': id},
    );
  }

  @override
  Future<bool> existsByDedupeKey({
    required String userId,
    required String dedupeKey,
  }) async {
    final rows = await _database.select(
      table: ApiConstants.notificationsTable,
      filters: {'user_id': userId, 'dedupe_key': dedupeKey},
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
