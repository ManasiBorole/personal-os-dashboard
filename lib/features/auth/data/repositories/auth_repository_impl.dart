import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState, AuthUser;

import 'package:personal_os_dashboard/core/error/exceptions.dart' as core;
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';
import 'package:personal_os_dashboard/features/auth/domain/repositories/auth_repository.dart';

/// Supabase-backed authentication repository.
final class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  AuthState get currentAuthState => _mapSession(_client.auth.currentSession);

  @override
  Stream<AuthState> watchAuthState() async* {
    yield currentAuthState;

    await for (final event in _client.auth.onAuthStateChange) {
      yield _mapSession(event.session);
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      throw core.AuthException(error.message, cause: error);
    } on Object catch (error) {
      throw core.AuthException('Sign in failed', cause: error);
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      throw core.AuthException(error.message, cause: error);
    } on Object catch (error) {
      throw core.AuthException('Sign up failed', cause: error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on Object catch (error) {
      throw core.AuthException('Sign out failed', cause: error);
    }
  }

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

/// Fallback repository when Supabase is not configured.
final class UnconfiguredAuthRepository implements AuthRepository {
  @override
  AuthState get currentAuthState => const AuthUnauthenticated();

  @override
  Stream<AuthState> watchAuthState() async* {
    yield const AuthUnauthenticated();
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    throw const core.AuthException(
      'Supabase is not configured. Add credentials to .env',
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    throw const core.AuthException(
      'Supabase is not configured. Add credentials to .env',
    );
  }

  @override
  Future<void> signOut() async {}
}
