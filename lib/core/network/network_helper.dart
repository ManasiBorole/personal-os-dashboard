import 'package:dio/dio.dart';

import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/core/error/exceptions.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';
import 'package:personal_os_dashboard/core/network/network_info.dart';

/// Enterprise HTTP client wrapper built on Dio.
final class NetworkHelper {
  NetworkHelper({
    required AppConfig config,
    required AppLogger logger,
    required ErrorHandler errorHandler,
    required NetworkInfo networkInfo,
    Dio? dio,
  })  : _config = config,
        _logger = logger,
        _errorHandler = errorHandler,
        _networkInfo = networkInfo,
        _dio = dio ?? Dio() {
    _configureDio();
  }

  final AppConfig _config;
  final AppLogger _logger;
  final ErrorHandler _errorHandler;
  final NetworkInfo _networkInfo;
  final Dio _dio;

  Dio get client => _dio;

  void _configureDio() {
    _dio.options = BaseOptions(
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    );

    _dio.interceptors.addAll([
      _LoggingInterceptor(_logger, _config),
      _ErrorInterceptor(_errorHandler),
    ]);
  }

  /// Updates the base URL for API requests.
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Sets or removes the authorization header.
  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }

    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Verifies connectivity before making a request.
  Future<void> ensureConnected() async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      throw const NetworkException('No internet connection available.');
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ensureConnected();
    return _execute(() => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ensureConnected();
    return _execute(() => _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ensureConnected();
    return _execute(() => _dio.put<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ensureConnected();
    return _execute(() => _dio.patch<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ensureConnected();
    return _execute(() => _dio.delete<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> _execute<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      final response = await request();

      if (response.statusCode != null &&
          response.statusCode! >= 400 &&
          response.statusCode! < 500) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Client error: ${response.statusCode}',
        );
      }

      return response;
    } on DioException catch (error) {
      final failure = _errorHandler.mapDioException(error);
      throw NetworkException(failure.message, cause: error);
    } on AppException {
      rethrow;
    } on Object catch (error) {
      throw NetworkException(
        _errorHandler.getUserMessage(error),
        cause: error,
      );
    }
  }
}

final class _LoggingInterceptor extends Interceptor {
  _LoggingInterceptor(this._logger, this._config);

  final AppLogger _logger;
  final AppConfig _config;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_config.environment.isProd) {
      _logger.debug('→ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (!_config.environment.isProd) {
      _logger.debug(
        '← ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning(
      '✕ ${err.requestOptions.method} ${err.requestOptions.uri}',
      error: err.message,
    );
    handler.next(err);
  }
}

final class _ErrorInterceptor extends Interceptor {
  _ErrorInterceptor(this._errorHandler);

  final ErrorHandler _errorHandler;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _errorHandler.handle(err, context: 'NetworkInterceptor');
    handler.next(err);
  }
}
