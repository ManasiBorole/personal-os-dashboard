import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';

/// Contract for loading dashboard aggregation data.
abstract interface class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary();
}
