/// UI state for authentication form submissions.
sealed class AuthFormState {
  const AuthFormState();
}

/// Form is idle and ready for input.
final class AuthFormIdle extends AuthFormState {
  const AuthFormIdle();
}

/// Form submission is in progress.
final class AuthFormLoading extends AuthFormState {
  const AuthFormLoading();
}

/// Form submission completed successfully.
final class AuthFormSuccess extends AuthFormState {
  const AuthFormSuccess({this.message});

  final String? message;
}

/// Form submission failed with an error message.
final class AuthFormError extends AuthFormState {
  const AuthFormError(this.message);

  final String message;
}

extension AuthFormStateX on AuthFormState {
  bool get isLoading => this is AuthFormLoading;

  bool get isSuccess => this is AuthFormSuccess;

  bool get isError => this is AuthFormError;

  String? get errorMessage => switch (this) {
        AuthFormError(:final message) => message,
        _ => null,
      };

  String? get successMessage => switch (this) {
        AuthFormSuccess(:final message) => message,
        _ => null,
      };
}
