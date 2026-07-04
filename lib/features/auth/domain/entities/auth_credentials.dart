import 'package:equatable/equatable.dart';

/// Credentials for sign-in and sign-up operations.
final class AuthCredentials extends Equatable {
  const AuthCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Parameters for password reset requests.
final class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}
