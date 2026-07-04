import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/settings/presentation/providers/settings_provider.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SwitchListTile(
              title: const Text('Profile visible'),
              subtitle: const Text('Allow teammates to see your profile details'),
              value: preferences.profileVisible,
              onChanged: (value) async {
                await ref.read(appPreferencesProvider.notifier).save(
                      preferences.copyWith(profileVisible: value),
                    );
              },
            ),
            SwitchListTile(
              title: const Text('Usage analytics'),
              subtitle: const Text('Help improve Personal OS with anonymous usage data'),
              value: preferences.analyticsEnabled,
              onChanged: (value) async {
                await ref.read(appPreferencesProvider.notifier).save(
                      preferences.copyWith(analyticsEnabled: value),
                    );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your data',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Personal OS stores your productivity data securely. You control '
              'what is visible to others and can export a backup from the Backup '
              'settings screen at any time.',
            ),
            const SizedBox(height: AppSpacing.lg),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.policy_outlined),
              title: Text('Privacy policy'),
              subtitle: Text('Learn how your data is handled'),
            ),
          ],
        ),
      ),
    );
  }
}
