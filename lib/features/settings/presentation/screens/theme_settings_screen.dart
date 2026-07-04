import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_entities.dart';
import 'package:personal_os_dashboard/features/settings/presentation/providers/settings_provider.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Choose how Personal OS looks on this device.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...AppThemePreference.values.map(
              (theme) => RadioListTile<AppThemePreference>(
                value: theme,
                groupValue: preferences.theme,
                title: Text(theme.label),
                subtitle: Text(_subtitleFor(theme)),
                onChanged: (value) async {
                  if (value == null) return;
                  await ref.read(themeModeProvider.notifier).setTheme(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(AppThemePreference theme) {
    return switch (theme) {
      AppThemePreference.system => 'Match your device settings',
      AppThemePreference.light => 'Always use light mode',
      AppThemePreference.dark => 'Always use dark mode',
    };
  }
}
