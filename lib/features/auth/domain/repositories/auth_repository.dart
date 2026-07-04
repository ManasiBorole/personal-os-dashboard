import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';

/// Contract for authentication session management.
abstract interface class AuthRepository {
  Stream<AuthState> watchAuthState();

  AuthState get currentAuthState;

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
