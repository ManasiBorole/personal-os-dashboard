import 'package:personal_os_dashboard/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Repository implementation for dashboard aggregation.
final class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remoteDataSource, {this.userName});

  final DashboardRemoteDataSource _remoteDataSource;
  final String? userName;

  @override
  Future<DashboardSummary> getDashboardSummary() {
    return _remoteDataSource.fetchSummary(userName: userName);
  }
}
