import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_report.dart';
import 'package:personal_os_dashboard/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:personal_os_dashboard/features/analytics/presentation/widgets/analytics_charts.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(analyticsReportProvider);
    final period = ref.watch(reportPeriodProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      body: reportAsync.when(
        loading: () => const LoadingView(message: 'Loading analytics...'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(analyticsReportProvider.notifier).refresh(),
        ),
        data: (report) => RefreshIndicator(
          onRefresh: () => ref.read(analyticsReportProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    isDesktop ? AppSpacing.xl : AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isDesktop)
                        Text(
                          'Analytics',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      if (!isDesktop) const SizedBox(height: AppSpacing.lg),
                      SegmentedButton<ReportPeriod>(
                        segments: [
                          for (final p in ReportPeriod.values)
                            ButtonSegment(value: p, label: Text(p.label)),
                        ],
                        selected: {period},
                        onSelectionChanged: (selection) {
                          ref
                              .read(analyticsReportProvider.notifier)
                              .setPeriod(selection.first);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${period.label} report · updated just now',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.crossAxisExtent >= 1024
                        ? 2
                        : 1;

                    final charts = [
                      AnalyticsChartCard(
                        title: 'Task Completion',
                        subtitle:
                            '${report.taskCompletion.completed} of ${report.taskCompletion.total} tasks completed',
                        child: TaskCompletionChart(stats: report.taskCompletion),
                      ),
                      AnalyticsChartCard(
                        title: 'Goal Progress',
                        subtitle: '${report.goalProgress.length} active goals',
                        child: GoalProgressChart(goals: report.goalProgress),
                      ),
                      AnalyticsChartCard(
                        title: 'Project Status',
                        subtitle: '${report.projectStatus.length} status groups',
                        child: ProjectStatusChart(statuses: report.projectStatus),
                      ),
                      AnalyticsChartCard(
                        title: 'Meetings',
                        subtitle: '${report.meetings.total} total meetings',
                        child: MeetingsChart(stats: report.meetings),
                      ),
                      AnalyticsChartCard(
                        title: 'Productivity',
                        subtitle: 'Composite score across modules',
                        child: ProductivityChart(stats: report.productivity),
                      ),
                    ];

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppSpacing.lg,
                        mainAxisSpacing: AppSpacing.lg,
                        childAspectRatio: crossAxisCount == 1 ? 1.1 : 1.15,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => charts[index],
                        childCount: charts.length,
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }
}
