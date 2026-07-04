import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/features/projects/data/datasources/local_projects_data_source.dart';
import 'package:personal_os_dashboard/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';
import 'package:personal_os_dashboard/features/projects/domain/usecases/project_usecases.dart';

void main() {
  late ProjectsRepositoryImpl repository;

  setUp(() {
    repository = ProjectsRepositoryImpl(LocalProjectsDataSource());
  });

  group('Project use cases', () {
    test('loads seeded projects for local user', () async {
      final result = await GetProjectsUseCase(repository).call('local-user');
      expect(result.isSuccess, isTrue);
      result.when(
        success: (projects) => expect(projects.length, greaterThanOrEqualTo(2)),
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('loads project dashboard with related data', () async {
      final result =
          await GetProjectDashboardUseCase(repository).call('proj-local-1');
      expect(result.isSuccess, isTrue);
      result.when(
        success: (dashboard) {
          expect(dashboard.members, isNotEmpty);
          expect(dashboard.tasks, isNotEmpty);
          expect(dashboard.files, isNotEmpty);
          expect(dashboard.notes, isNotEmpty);
        },
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('creates and deletes a project', () async {
      const userId = 'test-user';
      final createResult = await CreateProjectUseCase(repository).call(
        CreateProjectRequest(
          userId: userId,
          project: const CreateProjectParams(
            name: 'Test Project',
            description: 'Description',
            status: 'active',
            clientName: 'John',
            clientEmail: 'john@test.com',
            clientCompany: 'Test Co',
            clientPhone: '555',
            budgetAmount: 10000,
            budgetCurrency: 'USD',
            budgetSpent: 2000,
            startDate: null,
            endDate: null,
            progress: 0.2,
          ),
        ),
      );

      late String projectId;
      createResult.when(
        success: (p) => projectId = p.id,
        onFailure: (_) => fail('Create failed'),
      );

      final deleteResult = await DeleteProjectUseCase(repository).call(projectId);
      expect(deleteResult.isSuccess, isTrue);
    });
  });
}
