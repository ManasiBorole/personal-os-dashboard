import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';

final getDashboardSummaryUseCaseProvider =
    Provider<GetDashboardSummaryUseCase>((ref) {
  return GetDashboardSummaryUseCase(ref.watch(dashboardRepositoryProvider));
});

/// Dashboard summary with loading, error, and refresh support.
final dashboardSummaryProvider =
    AsyncNotifierProvider<DashboardController, DashboardSummary>(
  DashboardController.new,
);

class DashboardController extends AsyncNotifier<DashboardSummary> {
  @override
  Future<DashboardSummary> build() => _loadSummary();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadSummary);
  }

  Future<DashboardSummary> _loadSummary() async {
    final result =
        await ref.read(getDashboardSummaryUseCaseProvider).call(const NoParams());

    return result.when(
      success: (summary) => summary,
      onFailure: (failure) {
        throw sl<ErrorHandler>().getUserMessage(failure);
      },
    );
  }
}

/// Today's overview derived from dashboard summary.
final todayOverviewProvider = Provider<TodayOverview?>((ref) {
  return ref.watch(dashboardSummaryProvider).maybeWhen(
        data: (summary) => summary.todayOverview,
        orElse: () => null,
      );
});

/// Task summary derived from dashboard summary.
final taskSummaryProvider = Provider<TaskSummary?>((ref) {
  return ref.watch(dashboardSummaryProvider).maybeWhen(
        data: (summary) => summary.taskSummary,
        orElse: () => null,
      );
});

/// Goal progress list derived from dashboard summary.
final goalProgressProvider = Provider<List<GoalProgressItem>>((ref) {
  return ref.watch(dashboardSummaryProvider).maybeWhen(
        data: (summary) => summary.goals,
        orElse: () => const [],
      );
});

/// Project progress list derived from dashboard summary.
final projectProgressProvider = Provider<List<ProjectProgressItem>>((ref) {
  return ref.watch(dashboardSummaryProvider).maybeWhen(
        data: (summary) => summary.projects,
        orElse: () => const [],
      );
});

/// Upcoming meetings derived from dashboard summary.
final upcomingMeetingsProvider = Provider<List<UpcomingMeetingItem>>((ref) {
  return ref.watch(dashboardSummaryProvider).maybeWhen(
        data: (summary) => summary.meetings,
        orElse: () => const [],
      );
});

/// Calendar preview events derived from dashboard summary.
final calendarPreviewProvider = Provider<List<CalendarPreviewItem>>((ref) {
  return ref.watch(dashboardSummaryProvider).maybeWhen(
        data: (summary) => summary.calendarEvents,
        orElse: () => const [],
      );
});

/// Quick actions derived from dashboard summary.
final quickActionsProvider = Provider<List<QuickActionItem>>((ref) {
  return ref.watch(dashboardSummaryProvider).maybeWhen(
        data: (summary) => summary.quickActions,
        orElse: () => const [],
      );
});

/// Recent notes derived from dashboard summary.
final recentNotesProvider = Provider<List<RecentNoteItem>>((ref) {
  return ref.watch(dashboardSummaryProvider).maybeWhen(
        data: (summary) => summary.notes,
        orElse: () => const [],
      );
});

/// Analytics metrics derived from dashboard summary.
final analyticsMetricsProvider = Provider<List<AnalyticsMetric>>((ref) {
  return ref.watch(dashboardSummaryProvider).maybeWhen(
        data: (summary) => summary.analytics,
        orElse: () => const [],
      );
});
