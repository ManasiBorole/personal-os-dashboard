import 'package:personal_os_dashboard/core/error/result.dart';

/// Contract for repositories in the data layer.
abstract interface class BaseRepository {
  const BaseRepository();
}

/// Extension helpers for repository result handling.
extension RepositoryResultX<T> on Future<Result<T>> {
  Future<T> unwrap() async {
    final result = await this;
    return result.when(
      success: (value) => value,
      onFailure: (failure) => throw failure,
    );
  }
}
