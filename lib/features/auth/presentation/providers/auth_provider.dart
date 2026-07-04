import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_credentials.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_form_state.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';
import 'package:personal_os_dashboard/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:personal_os_dashboard/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:personal_os_dashboard/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:personal_os_dashboard/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:personal_os_dashboard/features/auth/domain/usecases/watch_auth_state_usecase.dart';

// Use cases

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final watchAuthStateUseCaseProvider = Provider<WatchAuthStateUseCase>((ref) {
  return WatchAuthStateUseCase(ref.watch(authRepositoryProvider));
});

// Session management

/// Stream of authentication state changes.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
});

/// Synchronous snapshot of the current authentication state.
final currentAuthStateProvider = Provider<AuthState>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return authAsync.maybeWhen(
    data: (state) => state,
    orElse: () => ref.watch(authRepositoryProvider).currentAuthState,
  );
});

/// Whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentAuthStateProvider).isAuthenticated;
});

/// Current authenticated user, if available.
final currentUserProvider = Provider<AuthUser?>((ref) {
  final state = ref.watch(currentAuthStateProvider);

  return switch (state) {
    AuthAuthenticated(:final user) => user,
    _ => null,
  };
});

// Form controllers

/// Login form state controller.
final loginControllerProvider =
    NotifierProvider<LoginController, AuthFormState>(LoginController.new);

class LoginController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormIdle();

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthFormLoading();

    final result = await ref.read(signInUseCaseProvider).call(
          AuthCredentials(email: email, password: password),
        );

    return result.when(
      success: (_) {
        state = const AuthFormSuccess();
        return true;
      },
      onFailure: (failure) {
        final message = sl<ErrorHandler>().getUserMessage(failure);
        state = AuthFormError(message);
        return false;
      },
    );
  }

  void clearStatus() => state = const AuthFormIdle();
}

/// Signup form state controller.
final signupControllerProvider =
    NotifierProvider<SignupController, AuthFormState>(SignupController.new);

class SignupController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormIdle();

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    state = const AuthFormLoading();

    final result = await ref.read(signUpUseCaseProvider).call(
          AuthCredentials(email: email, password: password),
        );

    return result.when(
      success: (_) {
        state = const AuthFormSuccess(
          message:
              'Account created. Check your email if confirmation is required.',
        );
        return true;
      },
      onFailure: (failure) {
        final message = sl<ErrorHandler>().getUserMessage(failure);
        state = AuthFormError(message);
        return false;
      },
    );
  }

  void clearStatus() => state = const AuthFormIdle();
}

/// Forgot password form state controller.
final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, AuthFormState>(
  ForgotPasswordController.new,
);

class ForgotPasswordController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormIdle();

  Future<bool> resetPassword({required String email}) async {
    state = const AuthFormLoading();

    final result = await ref.read(resetPasswordUseCaseProvider).call(
          ResetPasswordParams(email: email),
        );

    return result.when(
      success: (_) {
        state = const AuthFormSuccess(
          message: 'Password reset link sent. Check your email inbox.',
        );
        return true;
      },
      onFailure: (failure) {
        final message = sl<ErrorHandler>().getUserMessage(failure);
        state = AuthFormError(message);
        return false;
      },
    );
  }

  void clearStatus() => state = const AuthFormIdle();
}

/// Logout action controller.
final logoutControllerProvider =
    NotifierProvider<LogoutController, AuthFormState>(LogoutController.new);

class LogoutController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormIdle();

  Future<bool> signOut() async {
    state = const AuthFormLoading();

    final result =
        await ref.read(signOutUseCaseProvider).call(const NoParams());

    return result.when(
      success: (_) {
        state = const AuthFormSuccess(message: 'Signed out successfully.');
        return true;
      },
      onFailure: (failure) {
        final message = sl<ErrorHandler>().getUserMessage(failure);
        state = AuthFormError(message);
        return false;
      },
    );
  }

  void clearStatus() => state = const AuthFormIdle();
}
