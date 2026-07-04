import 'package:equatable/equatable.dart';

/// Authenticated user snapshot used for navigation and session state.
final class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    this.email,
  });

  final String id;
  final String? email;

  @override
  List<Object?> get props => [id, email];
}

/// Authentication state for route protection.
sealed class AuthState extends Equatable {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;
}

final class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  List<Object?> get props => [];
}
