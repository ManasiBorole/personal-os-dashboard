import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification.dart';
import 'package:personal_os_dashboard/features/notifications/domain/entities/notification_params.dart';
import 'package:personal_os_dashboard/features/notifications/domain/repositories/notifications_repository.dart';

typedef CreateNotificationRequest = ({
  String userId,
  CreateNotificationParams params,
});

final class GetNotificationsUseCase
    implements AsyncUseCase<List<AppNotification>, String> {
  const GetNotificationsUseCase(this._repository);
  final NotificationsRepository _repository;

  @override
  Future<Result<List<AppNotification>>> call(String userId) async {
    try {
      return Result.success(
        await _repository.getNotifications(userId: userId),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateNotificationUseCase
    implements AsyncUseCase<AppNotification, CreateNotificationRequest> {
  const CreateNotificationUseCase(this._repository);
  final NotificationsRepository _repository;

  @override
  Future<Result<AppNotification>> call(CreateNotificationRequest params) async {
    try {
      return Result.success(
        await _repository.createNotification(
          userId: params.userId,
          params: params.params,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class MarkNotificationReadUseCase
    implements AsyncUseCase<AppNotification, String> {
  const MarkNotificationReadUseCase(this._repository);
  final NotificationsRepository _repository;

  @override
  Future<Result<AppNotification>> call(String id) async {
    try {
      return Result.success(await _repository.markAsRead(id: id));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class MarkAllNotificationsReadUseCase
    implements AsyncUseCase<void, String> {
  const MarkAllNotificationsReadUseCase(this._repository);
  final NotificationsRepository _repository;

  @override
  Future<Result<void>> call(String userId) async {
    try {
      await _repository.markAllAsRead(userId: userId);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DeleteNotificationUseCase implements AsyncUseCase<void, String> {
  const DeleteNotificationUseCase(this._repository);
  final NotificationsRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteNotification(id: id);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetUnreadNotificationCountUseCase
    implements AsyncUseCase<int, String> {
  const GetUnreadNotificationCountUseCase(this._repository);
  final NotificationsRepository _repository;

  @override
  Future<Result<int>> call(String userId) async {
    try {
      return Result.success(
        await _repository.getUnreadCount(userId: userId),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}
