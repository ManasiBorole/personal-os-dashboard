import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/constants/app_constants.dart';
import 'package:personal_os_dashboard/core/theme/app_spacing.dart';
import 'package:personal_os_dashboard/core/utils/extensions/context_extensions.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/error_view.dart';
import 'package:personal_os_dashboard/core/widgets/feedback/loading_view.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/analytics_cards_row.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/calendar_preview_card.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/goal_progress_card.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/project_progress_card.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/quick_actions_bar.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/recent_notes_card.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/task_summary_card.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/today_overview_card.dart';
import 'package:personal_os_dashboard/features/dashboard/presentation/widgets/upcoming_meetings_card.dart';

/// Main dashboard command center screen.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    final isDesktop = context.isDesktop;

    return Scaffold(
      body: dashboardAsync.when(
        loading: () => const LoadingView(message: 'Loading dashboard...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(dashboardSummaryProvider.notifier).refresh(),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardSummaryProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.maxContentWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        isDesktop ? AppSpacing.xl : AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.xxxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isDesktop) ...[
                            Text(
                              'Dashboard',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          TodayOverviewCard(overview: summary.todayOverview),
                          const SizedBox(height: AppSpacing.lg),
                          AnalyticsCardsRow(metrics: summary.analytics),
                          const SizedBox(height: AppSpacing.lg),
                          QuickActionsBar(actions: summary.quickActions),
                          const SizedBox(height: AppSpacing.lg),
                          _DashboardGrid(
                            isDesktop: isDesktop,
                            isTablet: context.isTablet,
                            summary: summary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid({
    required this.isDesktop,
    required this.isTablet,
    required this.summary,
  });

  final bool isDesktop;
  final bool isTablet;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final useTwoColumns = isDesktop || isTablet;

    if (!useTwoColumns) {
      return Column(
        children: [
          TaskSummaryCard(summary: summary.taskSummary),
          const SizedBox(height: AppSpacing.lg),
          GoalProgressCard(goals: summary.goals),
          const SizedBox(height: AppSpacing.lg),
          ProjectProgressCard(projects: summary.projects),
          const SizedBox(height: AppSpacing.lg),
          UpcomingMeetingsCard(meetings: summary.meetings),
          const SizedBox(height: AppSpacing.lg),
          CalendarPreviewCard(events: summary.calendarEvents),
          const SizedBox(height: AppSpacing.lg),
          RecentNotesCard(notes: summary.notes),
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: TaskSummaryCard(summary: summary.taskSummary)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: GoalProgressCard(goals: summary.goals)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ProjectProgressCard(projects: summary.projects)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: UpcomingMeetingsCard(meetings: summary.meetings)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CalendarPreviewCard(events: summary.calendarEvents),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: RecentNotesCard(notes: summary.notes)),
          ],
        ),
      ],
    );
  }
}
