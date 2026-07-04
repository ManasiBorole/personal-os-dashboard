import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_params.dart';
import 'package:personal_os_dashboard/features/analytics/domain/entities/analytics_report.dart';
import 'package:personal_os_dashboard/features/analytics/domain/repositories/analytics_repository.dart';

final class GetAnalyticsReportUseCase
    implements AsyncUseCase<AnalyticsReport, GetAnalyticsReportParams> {
  const GetAnalyticsReportUseCase(this._repository);
  final AnalyticsRepository _repository;

  @override
  Future<Result<AnalyticsReport>> call(GetAnalyticsReportParams params) async {
    try {
      return Result.success(
        await _repository.getReport(
          userId: params.userId,
          period: params.period,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}
