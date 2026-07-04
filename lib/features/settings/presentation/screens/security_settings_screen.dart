import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/settings/presentation/providers/settings_provider.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(appPreferencesProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Signed in as'),
                subtitle: Text(user?.email ?? 'Guest'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              title: const Text('Biometric unlock'),
              subtitle: const Text('Use fingerprint or face ID when available'),
              value: preferences.biometricEnabled,
              onChanged: (value) async {
                await ref.read(appPreferencesProvider.notifier).save(
                      preferences.copyWith(biometricEnabled: value),
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset_outlined),
              title: const Text('Change password'),
              subtitle: const Text('Send a password reset link to your email'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteConstants.forgotPassword),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Security tips',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Use a strong unique password and enable biometric unlock on '
              'supported devices for faster secure access.',
            ),
          ],
        ),
      ),
    );
  }
}
