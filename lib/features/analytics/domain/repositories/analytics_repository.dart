import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_report.dart';

/// Analytics repository contract.
abstract interface class AnalyticsRepository {
  Future<AnalyticsReport> getReport({
    required String userId,
    required ReportPeriod period,
  });
}
