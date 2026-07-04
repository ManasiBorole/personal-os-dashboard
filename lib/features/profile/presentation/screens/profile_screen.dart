import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/router/route_paths.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_form_state.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_status_banner.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final logoutState = ref.watch(logoutControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AuthFormState>(logoutControllerProvider, (previous, next) {
      if (next is AuthFormSuccess) {
        context.go(RoutePaths.login);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      (user?.email?.substring(0, 1).toUpperCase() ?? '?'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email ?? 'Guest',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.id ?? 'Not signed in',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AuthStatusBanner(
            state: logoutState,
            onDismiss: () =>
                ref.read(logoutControllerProvider.notifier).clearStatus(),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: logoutState is AuthFormLoading
                ? null
                : () => ref.read(logoutControllerProvider.notifier).signOut(),
            icon: logoutState is AuthFormLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
            label: Text(
              logoutState is AuthFormLoading ? 'Signing out...' : 'Sign out',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go(RoutePaths.dashboard),
            child: const Text('Back to dashboard'),
          ),
        ],
      ),
    );
  }
}
