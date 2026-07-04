/// Application-level exception hierarchy for the data layer.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.cause, this.statusCode});

  final int? statusCode;
}

final class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

final class AuthException extends AppException {
  const AuthException(super.message, {super.cause});
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});
}

final class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause});
}

final class PermissionException extends AppException {
  const PermissionException(super.message, {super.cause});
}
