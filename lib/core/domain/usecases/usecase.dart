import 'package:personal_os_dashboard/core/error/result.dart';

/// Base contract for synchronous use cases.
abstract interface class UseCase<T, Params> {
  const UseCase();

  Result<T> call(Params params);
}

/// Base contract for asynchronous use cases.
abstract interface class AsyncUseCase<T, Params> {
  const AsyncUseCase();

  Future<Result<T>> call(Params params);
}

/// Base contract for stream-based use cases.
abstract interface class StreamUseCase<T, Params> {
  const StreamUseCase();

  Stream<Result<T>> call(Params params);
}

/// Marker for use cases that do not require parameters.
final class NoParams {
  const NoParams();
}
