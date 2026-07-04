import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/settings/presentation/providers/settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SwitchListTile(
              title: const Text('Push notifications'),
              subtitle: const Text(
                'Receive reminders for tasks, meetings, goals, and birthdays',
              ),
              value: preferences.notificationsEnabled,
              onChanged: (value) async {
                await ref.read(appPreferencesProvider.notifier).save(
                      preferences.copyWith(notificationsEnabled: value),
                    );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.inbox_outlined),
              title: const Text('Notification center'),
              subtitle: const Text('View your recent reminders and alerts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteConstants.notifications),
            ),
            const Divider(height: AppSpacing.xl),
            Text(
              'Reminder types',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ReminderTypeRow(
              icon: Icons.task_alt_outlined,
              label: 'Task reminders',
            ),
            const _ReminderTypeRow(
              icon: Icons.groups_outlined,
              label: 'Meeting reminders',
            ),
            const _ReminderTypeRow(
              icon: Icons.flag_outlined,
              label: 'Goal deadlines',
            ),
            const _ReminderTypeRow(
              icon: Icons.cake_outlined,
              label: 'Birthday reminders',
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTypeRow extends StatelessWidget {
  const _ReminderTypeRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
    );
  }
}
