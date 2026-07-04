import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:personal_os_dashboard/core/theme/app_colors.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/utils/dashboard_icons.dart';

/// Analytics metric cards with sparklines.
class AnalyticsCardsRow extends StatelessWidget {
  const AnalyticsCardsRow({
    required this.metrics,
    super.key,
  });

  final List<AnalyticsMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1024
            ? 4
            : constraints.maxWidth >= 600
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: crossAxisCount == 1 ? 2.8 : 1.5,
          ),
          itemBuilder: (context, index) => _AnalyticsCard(metric: metrics[index]),
        );
      },
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.metric});

  final AnalyticsMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendColor = switch (metric.trend) {
      AnalyticsTrend.up => AppColors.success,
      AnalyticsTrend.down => AppColors.error,
      AnalyticsTrend.neutral => theme.colorScheme.onSurfaceVariant,
    };
    final trendIcon = switch (metric.trend) {
      AnalyticsTrend.up => Icons.trending_up_rounded,
      AnalyticsTrend.down => Icons.trending_down_rounded,
      AnalyticsTrend.neutral => Icons.trending_flat_rounded,
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  dashboardIconForName(metric.iconName),
                  size: AppSpacing.iconMd,
                  color: theme.colorScheme.primary,
                ),
                const Spacer(),
                Icon(trendIcon, size: 16, color: trendColor),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  '${metric.changePercent.abs().toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall?.copyWith(color: trendColor),
                ),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              metric.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 36,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < metric.sparkline.length; i++)
                          FlSpot(i.toDouble(), metric.sparkline[i]),
                      ],
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
