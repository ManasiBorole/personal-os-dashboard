import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/features/dashboard/data/datasources/dashboard_sample_data.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';

class _FakeDashboardRepository implements DashboardRepository {
  _FakeDashboardRepository(this._summary);

  final DashboardSummary _summary;

  @override
  Future<DashboardSummary> getDashboardSummary() async => _summary;
}

void main() {
  group('GetDashboardSummaryUseCase', () {
    test('returns success with dashboard summary', () async {
      final summary = DashboardSampleData.build(userName: 'Alex');
      final useCase = GetDashboardSummaryUseCase(
        _FakeDashboardRepository(summary),
      );

      final result = await useCase.call(const NoParams());

      expect(result.isSuccess, isTrue);
      result.when(
        success: (data) {
          expect(data.todayOverview.greeting, contains('Alex'));
          expect(data.taskSummary.total, greaterThan(0));
          expect(data.goals, isNotEmpty);
          expect(data.quickActions, isNotEmpty);
        },
        onFailure: (_) => fail('Expected success'),
      );
    });
  });

  group('DashboardSampleData', () {
    test('builds complete summary with all sections', () {
      final summary = DashboardSampleData.build();

      expect(summary.analytics.length, 4);
      expect(summary.meetings, isNotEmpty);
      expect(summary.calendarEvents, isNotEmpty);
      expect(summary.notes, isNotEmpty);
      expect(summary.projects, isNotEmpty);
    });
  });
}
