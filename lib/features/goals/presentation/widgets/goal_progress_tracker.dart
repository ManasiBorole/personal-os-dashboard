import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';

/// Visual progress tracker with percentage label.
class GoalProgressTracker extends StatelessWidget {
  const GoalProgressTracker({
    required this.progress,
    super.key,
    this.showLabel = true,
    this.onChanged,
  });

  final double progress;
  final bool showLabel;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.labelLarge,
              ),
              Text(
                '$percent%',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        if (showLabel) const SizedBox(height: AppSpacing.sm),
        if (onChanged != null)
          Slider(
            value: progress.clamp(0, 1),
            onChanged: onChanged,
            divisions: 20,
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
      ],
    );
  }
}
