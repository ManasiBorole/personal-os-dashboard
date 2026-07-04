import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';
import 'package:personal_os_dashboard/features/auth/domain/repositories/auth_repository.dart';

/// Watches authentication state changes from the session.
final class WatchAuthStateUseCase
    implements StreamUseCase<AuthState, NoParams> {
  const WatchAuthStateUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Stream<Result<AuthState>> call(NoParams params) {
    return _repository.watchAuthState().map(Result.success);
  }
}
