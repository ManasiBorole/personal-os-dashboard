import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';

/// Shared layout scaffold for authentication screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    super.key,
    this.showBackButton = false,
  });

  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final isWide = context.isTablet || context.isDesktop;

    return Scaffold(
      body: Row(
        children: [
          if (isWide) const Expanded(child: _AuthBrandPanel()),
          Expanded(
            flex: isWide ? 1 : 1,
            child: SafeArea(
              child: Column(
                children: [
                  if (showBackButton)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  size: 56,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your personal and business life management platform.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
