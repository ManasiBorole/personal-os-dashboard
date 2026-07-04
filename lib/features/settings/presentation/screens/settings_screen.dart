import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_form_state.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';
import 'package:personal_os_dashboard/features/auth/presentation/widgets/auth_status_banner.dart';
import 'package:personal_os_dashboard/features/settings/presentation/providers/settings_provider.dart';
import 'package:personal_os_dashboard/features/settings/presentation/widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final preferencesAsync = ref.watch(appPreferencesProvider);
    final logoutState = ref.watch(logoutControllerProvider);
    final isDesktop = context.isDesktop;

    ref.listen<AuthFormState>(logoutControllerProvider, (previous, next) {
      if (next is AuthFormSuccess) {
        context.go(RouteConstants.login);
      }
    });

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) => ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            isDesktop ? AppSpacing.xl : AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            if (!isDesktop)
              Text(
                'Settings',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            if (!isDesktop) const SizedBox(height: AppSpacing.lg),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
                leading: CircleAvatar(
                  radius: 28,
                  child: Text(profile.initials),
                ),
                title: Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                subtitle: Text(profile.email),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(RouteConstants.profile),
              ),
            ),
            const SettingsSectionHeader(title: 'Account'),
            SettingsTile(
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'View your account details',
              onTap: () => context.push(RouteConstants.profile),
            ),
            SettingsTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update name, phone, and bio',
              onTap: () => context.push(RouteConstants.settingsEditProfile),
            ),
            const SettingsSectionHeader(title: 'Preferences'),
            SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: preferencesAsync.maybeWhen(
                data: (prefs) => prefs.theme.label,
                orElse: () => 'System',
              ),
              onTap: () => context.push(RouteConstants.settingsTheme),
            ),
            SettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: preferencesAsync.maybeWhen(
                data: (prefs) => prefs.language.label,
                orElse: () => 'English',
              ),
              onTap: () => context.push(RouteConstants.settingsLanguage),
            ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage reminder preferences',
              onTap: () => context.push(RouteConstants.settingsNotificationPrefs),
            ),
            const SettingsSectionHeader(title: 'Data & Privacy'),
            SettingsTile(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Password and biometric options',
              onTap: () => context.push(RouteConstants.settingsSecurity),
            ),
            SettingsTile(
              icon: Icons.backup_outlined,
              title: 'Backup',
              subtitle: preferencesAsync.maybeWhen(
                data: (prefs) => prefs.autoBackupEnabled
                    ? 'Auto backup enabled'
                    : 'Manual backup available',
                orElse: () => 'Backup your data',
              ),
              onTap: () => context.push(RouteConstants.settingsBackup),
            ),
            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy',
              subtitle: 'Control visibility and analytics',
              onTap: () => context.push(RouteConstants.settingsPrivacy),
            ),
            const SettingsSectionHeader(title: 'Session'),
            AuthStatusBanner(
              state: logoutState,
              onDismiss: () =>
                  ref.read(logoutControllerProvider.notifier).clearStatus(),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              onPressed: logoutState is AuthFormLoading
                  ? null
                  : () => _confirmLogout(context, ref),
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

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(logoutControllerProvider.notifier).signOut();
    }
  }
}
