import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_report.dart';

class AnalyticsChartCard extends StatelessWidget {
  const AnalyticsChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class TaskCompletionChart extends StatelessWidget {
  const TaskCompletionChart({required this.stats, super.key});

  final TaskCompletionStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = [
      if (stats.completed > 0)
        _section('Completed', stats.completed.toDouble(), AppColors.success),
      if (stats.inProgress > 0)
        _section('In Progress', stats.inProgress.toDouble(), AppColors.info),
      if (stats.pending > 0)
        _section('Pending', stats.pending.toDouble(), AppColors.warning),
      if (stats.overdue > 0)
        _section('Overdue', stats.overdue.toDouble(), AppColors.error),
    ];

    if (sections.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No task data')),
      );
    }

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(stats.completionRate * 100).round()}%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'completion',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                _legend('Completed', AppColors.success, stats.completed),
                _legend('In Progress', AppColors.info, stats.inProgress),
                _legend('Pending', AppColors.warning, stats.pending),
                _legend('Overdue', AppColors.error, stats.overdue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(String title, double value, Color color) {
    return PieChartSectionData(
      value: value,
      title: value > 0 ? '${value.toInt()}' : '',
      color: color,
      radius: 50,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  Widget _legend(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text('$label ($count)', style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class GoalProgressChart extends StatelessWidget {
  const GoalProgressChart({required this.goals, super.key});

  final List<GoalProgressPoint> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No goals to display')),
      );
    }

    final theme = Theme.of(context);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.dividerColor.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}',
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= goals.length) {
                    return const SizedBox.shrink();
                  }
                  final title = goals[index].title;
                  final short = title.length > 6
                      ? '${title.substring(0, 6)}…'
                      : title;
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(short, style: theme.textTheme.labelSmall),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < goals.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: goals[i].progress,
                    color: AppColors.secondary,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ProjectStatusChart extends StatelessWidget {
  const ProjectStatusChart({required this.statuses, super.key});

  final List<ProjectStatusPoint> statuses;

  static const _colors = [
    AppColors.info,
    AppColors.success,
    AppColors.warning,
    AppColors.accent,
    AppColors.error,
  ];

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No projects to display')),
      );
    }

    final theme = Theme.of(context);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: statuses.map((s) => s.count).reduce((a, b) => a > b ? a : b).toDouble() + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.dividerColor.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= statuses.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      statuses[index].status,
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < statuses.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: statuses[i].count.toDouble(),
                    color: _colors[i % _colors.length],
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class MeetingsChart extends StatelessWidget {
  const MeetingsChart({required this.stats, super.key});

  final MeetingsStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trend = stats.trend;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statChip(context, 'Scheduled', stats.scheduled, AppColors.info),
            _statChip(context, 'Completed', stats.completed, AppColors.success),
            _statChip(context, 'Cancelled', stats.cancelled, AppColors.error),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 160,
          child: trend.isEmpty
              ? const Center(child: Text('No meeting trend data'))
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: theme.dividerColor.withValues(alpha: 0.4),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, _) => Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= trend.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              trend[index].label,
                              style: theme.textTheme.labelSmall,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < trend.length; i++)
                            FlSpot(i.toDouble(), trend[i].value),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _statChip(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class ProductivityChart extends StatelessWidget {
  const ProductivityChart({required this.stats, super.key});

  final ProductivityStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trend = stats.trend;
    final changeColor = stats.changePercent >= 0
        ? AppColors.success
        : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${stats.score}',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    stats.changePercent >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 14,
                    color: changeColor,
                  ),
                  Text(
                    '${stats.changePercent.abs().toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall?.copyWith(color: changeColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          'Productivity score',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 180,
          child: trend.isEmpty
              ? const Center(child: Text('No productivity trend'))
              : LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 100,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 25,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: theme.dividerColor.withValues(alpha: 0.4),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 25,
                          getTitlesWidget: (value, _) => Text(
                            '${value.toInt()}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= trend.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              trend[index].label,
                              style: theme.textTheme.labelSmall,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < trend.length; i++)
                            FlSpot(i.toDouble(), trend[i].value),
                        ],
                        isCurved: true,
                        color: AppColors.secondary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.secondary.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
