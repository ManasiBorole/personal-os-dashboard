import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/settings/domain/entities/settings_entities.dart';
import 'package:personal_os_dashboard/features/settings/presentation/providers/settings_provider.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Select your preferred language for the app interface.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...AppLanguage.values.map(
              (language) => ListTile(
                title: Text(language.label),
                subtitle: Text(language.locale.toLanguageTag()),
                selected: preferences.language == language,
                trailing: preferences.language == language
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () async {
                  if (preferences.language == language) return;
                  await ref.read(localeProvider.notifier).setLanguage(language);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
