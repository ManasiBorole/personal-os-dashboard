import 'dart:async';

import 'package:personal_os_dashboard/core/constants/storage_constants.dart';
import 'package:personal_os_dashboard/core/storage/storage_helper.dart';
import 'package:personal_os_dashboard/features/auth/data/constants/local_dev_auth_config.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';
import 'package:personal_os_dashboard/features/auth/domain/repositories/auth_repository.dart';

/// Offline authentication for development when Supabase is not configured.
final class LocalDevAuthRepository implements AuthRepository {
  LocalDevAuthRepository(this._storage) {
    _state = _restoreSession();
  }

  final StorageHelper _storage;
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  late AuthState _state;
  bool _seeded = false;

  @override
  AuthState get currentAuthState => _state;

  @override
  Stream<AuthState> watchAuthState() async* {
    await _ensureSeeded();
    yield _state;
    yield* _authStateController.stream;
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureSeeded();

    final normalizedEmail = _normalizeEmail(email);
    final userId = _userIdForEmail(normalizedEmail);
    final users = _readUsers();

    users[normalizedEmail] = {
      'id': userId,
      'password': password,
    };
    await _storage.writeCache(StorageConstants.localDevUsersCacheKey, users);

    await _setAuthenticated(
      AuthUser(
        id: userId,
        email: normalizedEmail,
      ),
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _ensureSeeded();

    final normalizedEmail = _normalizeEmail(email);
    final userId = _userIdForEmail(normalizedEmail);
    final users = _readUsers();

    users[normalizedEmail] = {
      'id': userId,
      'password': password,
    };
    await _storage.writeCache(StorageConstants.localDevUsersCacheKey, users);

    await _setAuthenticated(
      AuthUser(
        id: userId,
        email: normalizedEmail,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    await _setUnauthenticated();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _ensureSeeded();
    // Local dev mode has no email delivery — sign-in still uses stored password.
  }

  Future<void> _ensureSeeded() async {
    if (_seeded) return;

    final users = _readUsers();
    final testEmail = _normalizeEmail(LocalDevAuthConfig.testEmail);

    if (!users.containsKey(testEmail)) {
      users[testEmail] = {
        'id': 'local-test-user',
        'password': LocalDevAuthConfig.testPassword,
      };
      await _storage.writeCache(StorageConstants.localDevUsersCacheKey, users);
    }

    _seeded = true;
  }

  AuthState _restoreSession() {
    final session = _storage.readSetting<Map<dynamic, dynamic>>(
      StorageConstants.localDevSessionKey,
    );

    if (session == null) {
      return const AuthUnauthenticated();
    }

    final id = session['id'] as String?;
    final email = session['email'] as String?;

    if (id == null || id.isEmpty) {
      return const AuthUnauthenticated();
    }

    return AuthAuthenticated(AuthUser(id: id, email: email));
  }

  Map<String, Map<String, String>> _readUsers() {
    final raw = _storage.readCache<Map<dynamic, dynamic>>(
      StorageConstants.localDevUsersCacheKey,
    );

    if (raw == null) {
      return {};
    }

    return raw.map(
      (key, value) => MapEntry(
        key.toString(),
        (value as Map<dynamic, dynamic>).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ),
      ),
    );
  }

  Future<void> _setAuthenticated(AuthUser user) async {
    _state = AuthAuthenticated(user);
    await _storage.writeSetting(StorageConstants.localDevSessionKey, {
      'id': user.id,
      'email': user.email,
    });
    _authStateController.add(_state);
  }

  Future<void> _setUnauthenticated() async {
    _state = const AuthUnauthenticated();
    await _storage.deleteSetting(StorageConstants.localDevSessionKey);
    _authStateController.add(_state);
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _userIdForEmail(String email) =>
      'local-${email.replaceAll(RegExp(r'[^a-z0-9]'), '-')}';
}
