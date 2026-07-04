import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Loads the aggregated dashboard summary.
final class GetDashboardSummaryUseCase
    implements AsyncUseCase<DashboardSummary, NoParams> {
  const GetDashboardSummaryUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Result<DashboardSummary>> call(NoParams params) async {
    try {
      final summary = await _repository.getDashboardSummary();
      return Result.success(summary);
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}
