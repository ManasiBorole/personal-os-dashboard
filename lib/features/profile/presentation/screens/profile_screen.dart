import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_form_state.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_status_banner.dart';
import 'package:personal_os_dashboard/features/settings/presentation/providers/settings_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final logoutState = ref.watch(logoutControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AuthFormState>(logoutControllerProvider, (previous, next) {
      if (next is AuthFormSuccess) {
        context.go(RouteConstants.login);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteConstants.settings),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        profile.initials,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            profile.email,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (profile.phone != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              profile.phone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (profile.bio.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Card(
                child: ListTile(
                  title: const Text('Bio'),
                  subtitle: Text(profile.bio),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteConstants.settingsEditProfile),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteConstants.settings),
            ),
            const SizedBox(height: AppSpacing.md),
            AuthStatusBanner(
              state: logoutState,
              onDismiss: () =>
                  ref.read(logoutControllerProvider.notifier).clearStatus(),
            ),
            const SizedBox(height: AppSpacing.sm),
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
                logoutState is AuthFormLoading ? 'Signing out...' : 'Logout',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
