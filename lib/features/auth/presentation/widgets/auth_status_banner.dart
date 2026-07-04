import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/auth/domain/entities/auth_form_state.dart';

/// Displays loading, error, or success feedback for auth forms.
class AuthStatusBanner extends StatelessWidget {
  const AuthStatusBanner({
    required this.state,
    super.key,
    this.onDismiss,
  });

  final AuthFormState state;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AuthFormError(:final message) => _Banner(
          icon: Icons.error_outline,
          message: message,
          backgroundColor: AppColors.errorLight,
          foregroundColor: AppColors.errorDark,
          onDismiss: onDismiss,
        ),
      AuthFormSuccess(:final message) when message != null => _Banner(
          icon: Icons.check_circle_outline,
          message: message,
          backgroundColor: AppColors.successLight,
          foregroundColor: AppColors.successDark,
          onDismiss: onDismiss,
        ),
      AuthFormLoading() => _Banner(
          icon: null,
          message: 'Processing...',
          backgroundColor: AppColors.infoLight,
          foregroundColor: AppColors.infoDark,
          showProgress: true,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    this.onDismiss,
    this.showProgress = false,
  });

  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;
  final VoidCallback? onDismiss;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          if (showProgress)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foregroundColor,
              ),
            )
          else if (icon != null)
            Icon(icon, color: foregroundColor, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, color: foregroundColor, size: 18),
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
