import 'package:dio/dio.dart';

import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/exceptions.dart';
import 'package:personal_os_dashboard/core/error/failures.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';

/// Centralized error handling for exceptions, failures, and Dio errors.
final class ErrorHandler {
  ErrorHandler(this._logger);

  final AppLogger _logger;

  /// Maps any error to a domain [Failure].
  Failure mapToFailure(Object error) {
    if (error is Failure) {
      return error;
    }

    if (error is DioException) {
      return mapDioException(error);
    }

    if (error is AppException) {
      return ExceptionMapper.mapException(error);
    }

    return ExceptionMapper.mapException(error);
  }

  /// Returns a user-friendly message for display in the UI.
  String getUserMessage(Object error) {
    final failure = mapToFailure(error);
    return _failureMessage(failure);
  }

  /// Logs the error and returns the mapped failure.
  Failure handle(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final failure = mapToFailure(error);
    final prefix = context != null ? '[$context] ' : '';

    _logger.error(
      '${prefix}Handled error: ${failure.message}',
      error: error,
      stackTrace: stackTrace,
    );

    return failure;
  }

  /// Maps [DioException] to domain failures.
  Failure mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        const NetworkFailure('Connection timed out. Please try again.'),
      DioExceptionType.connectionError =>
        const NetworkFailure('No internet connection. Check your network.'),
      DioExceptionType.badCertificate =>
        const NetworkFailure('Secure connection failed.'),
      DioExceptionType.cancel =>
        const NetworkFailure('Request was cancelled.'),
      DioExceptionType.badResponse => _mapStatusCode(error),
      DioExceptionType.unknown => NetworkFailure(
          error.message ?? 'An unexpected network error occurred.',
        ),
    };
  }

  Failure _mapStatusCode(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = _extractResponseMessage(error);

    if (statusCode == null) {
      return ServerFailure(message ?? 'Request failed.');
    }

    return switch (statusCode) {
      400 => ValidationFailure(message ?? 'Invalid request.'),
      401 => AuthFailure(message ?? 'Session expired. Please sign in again.'),
      403 => PermissionFailure(message ?? 'You do not have permission.'),
      404 => NotFoundFailure(message ?? 'Resource not found.'),
      409 => ValidationFailure(message ?? 'Conflict with existing data.'),
      422 => ValidationFailure(message ?? 'Validation failed.'),
      >= 500 => ServerFailure(
          message ?? 'Server error. Please try again later.',
          statusCode: statusCode,
        ),
      _ => ServerFailure(
          message ?? 'Request failed.',
          statusCode: statusCode,
        ),
    };
  }

  String? _extractResponseMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['error_description'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return error.message;
  }

  String _failureMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() =>
        'No internet connection. Please check your network and try again.',
      AuthFailure() => failure.message,
      ValidationFailure() => failure.message,
      NotFoundFailure() => failure.message,
      PermissionFailure() => 'You do not have permission to perform this action.',
      ServerFailure() => 'Something went wrong on our end. Please try again later.',
      CacheFailure() => 'Unable to load cached data.',
      StorageFailure() => 'Unable to save data locally.',
      UnexpectedFailure() => 'An unexpected error occurred. Please try again.',
    };
  }
}
