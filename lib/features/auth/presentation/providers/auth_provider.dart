import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_state.dart';

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
