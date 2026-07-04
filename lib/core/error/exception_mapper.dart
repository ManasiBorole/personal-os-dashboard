import 'package:personal_os_dashboard/core/error/exceptions.dart';
import 'package:personal_os_dashboard/core/error/failures.dart';

/// Maps data layer exceptions to domain failures.
abstract final class ExceptionMapper {
  static Failure mapException(Object error) {
    return switch (error) {
      ServerException(:final message, :final statusCode) =>
        ServerFailure(message, statusCode: statusCode),
      CacheException(:final message) => CacheFailure(message),
      NetworkException(:final message) => NetworkFailure(message),
      AuthException(:final message) => AuthFailure(message),
      ValidationException(:final message) => ValidationFailure(message),
      StorageException(:final message) => StorageFailure(message),
      NotFoundException(:final message) => NotFoundFailure(message),
      PermissionException(:final message) => PermissionFailure(message),
      final Failure mappedFailure => mappedFailure,
      _ => UnexpectedFailure(error.toString()),
    };
  }
}
