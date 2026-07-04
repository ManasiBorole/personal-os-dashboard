import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/failures.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_credentials.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';
import 'package:personal_os_dashboard/features/auth/domain/repositories/auth_repository.dart';
import 'package:personal_os_dashboard/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:personal_os_dashboard/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:personal_os_dashboard/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:personal_os_dashboard/features/auth/domain/usecases/sign_up_usecase.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.onSignIn,
    this.onSignUp,
    this.onSignOut,
    this.onResetPassword,
  });

  final Future<void> Function(String email, String password)? onSignIn;
  final Future<void> Function(String email, String password)? onSignUp;
  final Future<void> Function()? onSignOut;
  final Future<void> Function(String email)? onResetPassword;

  @override
  AuthState get currentAuthState => const AuthUnauthenticated();

  @override
  Stream<AuthState> watchAuthState() => Stream.value(const AuthUnauthenticated());

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) =>
      onSignIn?.call(email, password) ?? Future.value();

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) =>
      onSignUp?.call(email, password) ?? Future.value();

  @override
  Future<void> signOut() => onSignOut?.call() ?? Future.value();

  @override
  Future<void> resetPassword({required String email}) =>
      onResetPassword?.call(email) ?? Future.value();
}

void main() {
  group('SignInUseCase', () {
    test('returns success when repository signs in', () async {
      var called = false;
      final repository = _FakeAuthRepository(
        onSignIn: (email, password) async {
          called = true;
          expect(email, 'user@example.com');
          expect(password, 'password123');
        },
      );

      final result = await SignInUseCase(repository).call(
        const AuthCredentials(email: 'user@example.com', password: 'password123'),
      );

      expect(called, isTrue);
      expect(result.isSuccess, isTrue);
    });

    test('returns failure when repository throws', () async {
      final repository = _FakeAuthRepository(
        onSignIn: (_, _) => throw Exception('Invalid credentials'),
      );

      final result = await SignInUseCase(repository).call(
        const AuthCredentials(email: 'user@example.com', password: 'wrong'),
      );

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('Expected failure'),
        onFailure: (failure) => expect(failure, isA<Failure>()),
      );
    });
  });

  group('SignUpUseCase', () {
    test('returns success when repository signs up', () async {
      final repository = _FakeAuthRepository(
        onSignUp: (email, password) async {
          expect(email, 'new@example.com');
          expect(password, 'password123');
        },
      );

      final result = await SignUpUseCase(repository).call(
        const AuthCredentials(email: 'new@example.com', password: 'password123'),
      );

      expect(result.isSuccess, isTrue);
    });
  });

  group('SignOutUseCase', () {
    test('returns success when repository signs out', () async {
      var called = false;
      final repository = _FakeAuthRepository(
        onSignOut: () async => called = true,
      );

      final result = await SignOutUseCase(repository).call(const NoParams());

      expect(called, isTrue);
      expect(result.isSuccess, isTrue);
    });
  });

  group('ResetPasswordUseCase', () {
    test('returns success when repository sends reset email', () async {
      var called = false;
      final repository = _FakeAuthRepository(
        onResetPassword: (email) async {
          called = true;
          expect(email, 'user@example.com');
        },
      );

      final result = await ResetPasswordUseCase(repository).call(
        const ResetPasswordParams(email: 'user@example.com'),
      );

      expect(called, isTrue);
      expect(result.isSuccess, isTrue);
    });
  });
}
