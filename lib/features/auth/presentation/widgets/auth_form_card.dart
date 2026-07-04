import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';

/// Card container for authentication form content.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: child,
      ),
    );
  }
}
