import 'package:personal_os_dashboard/core/config/app_config.dart';
import 'package:personal_os_dashboard/core/error/exceptions.dart' as core;
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/auth_remote_datasource.dart';
import 'package:personal_os_dashboard/features/auth/data/constants/local_dev_auth_config.dart';
import 'package:personal_os_dashboard/features/auth/data/repositories/local_dev_auth_repository.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';
import 'package:personal_os_dashboard/features/auth/domain/repositories/auth_repository.dart';

/// Repository implementation delegating to [AuthRemoteDataSource].
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  AuthState get currentAuthState => _remoteDataSource.currentAuthState;

  @override
  Stream<AuthState> watchAuthState() => _remoteDataSource.watchAuthState();

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) =>
      _remoteDataSource.signIn(email: email, password: password);

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) =>
      _remoteDataSource.signUp(email: email, password: password);

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  Future<void> resetPassword({required String email}) =>
      _remoteDataSource.resetPassword(email: email);
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

  @override
  Future<void> resetPassword({required String email}) async {
    throw const core.AuthException(
      'Supabase is not configured. Add credentials to .env',
    );
  }
}

/// Factory for creating the appropriate [AuthRepository].
AuthRepository createAuthRepository({
  required bool isSupabaseReady,
  required AuthRemoteDataSource remoteDataSource,
  required AppConfig config,
  required StorageHelper storageHelper,
}) {
  if (isSupabaseReady) {
    return AuthRepositoryImpl(remoteDataSource);
  }

  if (config.isLocalAuthMode && LocalDevAuthConfig.isEnabled) {
    return LocalDevAuthRepository(storageHelper);
  }

  return UnconfiguredAuthRepository();
}
