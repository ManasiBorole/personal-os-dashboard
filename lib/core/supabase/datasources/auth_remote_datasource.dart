import 'package:personal_os_dashboard/core/supabase/services/auth_service.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';

/// Remote data source for authentication operations.
abstract interface class AuthRemoteDataSource {
  AuthState get currentAuthState;

  Stream<AuthState> watchAuthState();

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword({required String email});
}

/// Supabase-backed implementation of [AuthRemoteDataSource].
final class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  SupabaseAuthRemoteDataSource(this._authService);

  final AuthService _authService;

  @override
  AuthState get currentAuthState => _authService.currentAuthState;

  @override
  Stream<AuthState> watchAuthState() => _authService.watchAuthState();

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) =>
      _authService.signIn(email: email, password: password);

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) =>
      _authService.signUp(email: email, password: password);

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<void> resetPassword({required String email}) =>
      _authService.resetPassword(email: email);
}
