import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState, AuthUser;

import 'package:personal_os_dashboard/core/error/exceptions.dart' as core;
import 'package:personal_os_dashboard/core/supabase/supabase_exception.dart';
import 'package:personal_os_dashboard/core/supabase/supabase_service.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';

/// Authentication service backed by the Supabase Auth client.
final class AuthService {
  AuthService(this._supabaseService);

  final SupabaseService _supabaseService;

  bool get isAvailable =>
      _supabaseService.isConfigured && _supabaseService.isInitialized;

  GoTrueClient get _auth {
    if (!isAvailable) {
      throw const SupabaseNotConfiguredException();
    }

    return _supabaseService.auth;
  }

  AuthState get currentAuthState {
    if (!isAvailable) {
      return const AuthUnauthenticated();
    }

    return _mapSession(_auth.currentSession);
  }

  Stream<AuthState> watchAuthState() async* {
    if (!isAvailable) {
      yield const AuthUnauthenticated();
      return;
    }

    yield currentAuthState;

    await for (final event in _auth.onAuthStateChange) {
      yield _mapSession(event.session);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      throw core.AuthException(error.message, cause: error);
    } on Object catch (error) {
      throw core.AuthException('Sign in failed', cause: error);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signUp(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      throw core.AuthException(error.message, cause: error);
    } on Object catch (error) {
      throw core.AuthException('Sign up failed', cause: error);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on Object catch (error) {
      throw core.AuthException('Sign out failed', cause: error);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (error) {
      throw core.AuthException(error.message, cause: error);
    } on Object catch (error) {
      throw core.AuthException('Password reset failed', cause: error);
    }
  }

  Session? get currentSession => isAvailable ? _auth.currentSession : null;

  AuthState _mapSession(Session? session) {
    if (session == null) {
      return const AuthUnauthenticated();
    }

    return AuthAuthenticated(
      AuthUser(
        id: session.user.id,
        email: session.user.email,
      ),
    );
  }
}
