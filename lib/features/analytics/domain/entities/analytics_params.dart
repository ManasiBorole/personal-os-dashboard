import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_report.dart';

/// Request parameters for analytics report.
final class GetAnalyticsReportParams {
  const GetAnalyticsReportParams({
    required this.userId,
    required this.period,
  });

  final String userId;
  final ReportPeriod period;
}
