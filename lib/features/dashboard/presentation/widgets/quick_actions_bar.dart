import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/utils/dashboard_icons.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/dashboard_card.dart';

/// Horizontal quick action shortcuts.
class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({
    required this.actions,
    super.key,
  });

  final List<QuickActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Quick Actions',
      subtitle: 'Jump to common workflows',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final itemWidth = isWide ? 120.0 : 100.0;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  _QuickActionButton(
                    action: actions[i],
                    width: itemWidth,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.action,
    required this.width,
  });

  final QuickActionItem action;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.chartColors[action.colorIndex % AppColors.chartColors.length];

    return SizedBox(
      width: width,
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
          onTap: () => context.go(action.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              children: [
                Icon(
                  dashboardIconForName(action.iconName),
                  color: color,
                  size: AppSpacing.iconLg,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  action.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
