import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_os_dashboard/core/di/core_providers.dart';
import 'package:personal_os_dashboard/core/di/service_locator.dart';
import 'package:personal_os_dashboard/core/error/error_handler.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_params.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_report.dart';
import 'package:personal_os_dashboard/features/analytics/domain/usecases/analytics_usecases.dart';
import 'package:personal_os_dashboard/features/auth/presentation/providers/auth_provider.dart';

final getAnalyticsReportUseCaseProvider = Provider<GetAnalyticsReportUseCase>((ref) {
  return GetAnalyticsReportUseCase(ref.watch(analyticsRepositoryProvider));
});

final reportPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.weekly);

final analyticsReportProvider =
    AsyncNotifierProvider<AnalyticsReportController, AnalyticsReport>(
  AnalyticsReportController.new,
);

class AnalyticsReportController extends AsyncNotifier<AnalyticsReport> {
  @override
  Future<AnalyticsReport> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> setPeriod(ReportPeriod period) async {
    ref.read(reportPeriodProvider.notifier).state = period;
    await refresh();
  }

  Future<AnalyticsReport> _load() async {
    final userId = ref.read(currentUserProvider)?.id ?? 'local-user';
    final period = ref.read(reportPeriodProvider);
    final result = await ref.read(getAnalyticsReportUseCaseProvider).call(
          GetAnalyticsReportParams(userId: userId, period: period),
        );
    return result.when(
      success: (report) => report,
      onFailure: (f) => throw sl<ErrorHandler>().getUserMessage(f),
    );
  }
}
