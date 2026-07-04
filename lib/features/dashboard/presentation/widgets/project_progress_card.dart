import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/dashboard_card.dart';

/// Project progress list with task counts.
class ProjectProgressCard extends StatelessWidget {
  const ProjectProgressCard({
    required this.projects,
    super.key,
  });

  final List<ProjectProgressItem> projects;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Project Progress',
      subtitle: '${projects.length} active projects',
      child: projects.isEmpty
          ? const Text('No projects yet.')
          : Column(
              children: [
                for (var i = 0; i < projects.length; i++) ...[
                  if (i > 0) const Divider(height: AppSpacing.xl),
                  _ProjectRow(project: projects[i], index: i),
                ],
              ],
            ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    required this.project,
    required this.index,
  });

  final ProjectProgressItem project;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.chartColors[index % AppColors.chartColors.length];
    final percent = (project.progress * 100).round();

    return Row(
      children: [
        Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                child: LinearProgressIndicator(
                  value: project.progress,
                  minHeight: 6,
                  color: color,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${project.completedTasks}/${project.totalTasks} tasks • ${project.status}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
