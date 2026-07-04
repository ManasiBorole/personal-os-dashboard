import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/constants/route_constants.dart';
import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/buttons/app_button.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';

/// User profile screen with session details and sign-out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Text(
                (user?.email?.isNotEmpty ?? false)
                    ? user!.email![0].toUpperCase()
                    : '?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProfileTile(
            label: 'Email',
            value: user?.email ?? 'Not available',
          ),
          _ProfileTile(
            label: 'User ID',
            value: user?.id ?? 'Not available',
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Sign Out',
            variant: AppButtonVariant.outlined,
            isExpanded: true,
            icon: Icons.logout,
            onPressed: () async {
              try {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  context.go(RouteConstants.login);
                }
              } on Object catch (error) {
                if (context.mounted) {
                  final message =
                      ref.read(errorHandlerProvider).getUserMessage(error);
                  context.showAppSnackBar(message);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
