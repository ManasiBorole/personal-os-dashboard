import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/settings/presentation/providers/settings_provider.dart';

class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() =>
      _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen> {
  bool _backingUp = false;

  Future<void> _runBackup() async {
    setState(() => _backingUp = true);
    try {
      final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
      final result = await ref.read(createBackupUseCaseProvider).call(userId);
      result.when(
        success: (summary) {
          ref.invalidate(appPreferencesProvider);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Backup created with ${summary.itemCount} sections',
              ),
            ),
          );
        },
        onFailure: (f) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message)),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencesAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Back up your profile and preferences. Module data syncs through '
              'Supabase when connected.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              title: const Text('Automatic backup'),
              subtitle: const Text('Create a local backup snapshot weekly'),
              value: preferences.autoBackupEnabled,
              onChanged: (value) async {
                await ref.read(appPreferencesProvider.notifier).save(
                      preferences.copyWith(autoBackupEnabled: value),
                    );
              },
            ),
            if (preferences.lastBackupAt != null) ...[
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Last backup'),
                subtitle: Text(
                  DateFormat('MMM d, y • h:mm a').format(
                    preferences.lastBackupAt!,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _backingUp ? 'Creating backup...' : 'Back up now',
              onPressed: _backingUp ? null : _runBackup,
              isLoading: _backingUp,
            ),
          ],
        ),
      ),
    );
  }
}
