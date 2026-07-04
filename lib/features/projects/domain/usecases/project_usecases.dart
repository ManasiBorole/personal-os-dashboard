import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';
import 'package:personal_os_dashboard/features/projects/domain/repositories/projects_repository.dart';

final class GetProjectsUseCase implements AsyncUseCase<List<Project>, String> {
  const GetProjectsUseCase(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<List<Project>>> call(String userId) async {
    try {
      return Result.success(await _repository.getProjects(userId: userId));
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class GetProjectByIdUseCase implements AsyncUseCase<Project, String> {
  const GetProjectByIdUseCase(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<Project>> call(String id) async {
    try {
      return Result.success(await _repository.getProjectById(id: id));
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class GetProjectDashboardUseCase
    implements AsyncUseCase<ProjectDashboard, String> {
  const GetProjectDashboardUseCase(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<ProjectDashboard>> call(String projectId) async {
    try {
      return Result.success(
        await _repository.getProjectDashboard(projectId: projectId),
      );
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class CreateProjectUseCase
    implements AsyncUseCase<Project, CreateProjectRequest> {
  const CreateProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<Project>> call(CreateProjectRequest params) async {
    try {
      return Result.success(
        await _repository.createProject(
          userId: params.userId,
          params: params.project,
        ),
      );
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class UpdateProjectUseCase
    implements AsyncUseCase<Project, UpdateProjectRequest> {
  const UpdateProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<Project>> call(UpdateProjectRequest params) async {
    try {
      return Result.success(
        await _repository.updateProject(
          userId: params.userId,
          params: params.project,
        ),
      );
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class DeleteProjectUseCase implements AsyncUseCase<void, String> {
  const DeleteProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteProject(id: id);
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(ExceptionMapper.mapException(error));
    }
  }
}

final class CreateProjectRequest {
  const CreateProjectRequest({required this.userId, required this.project});

  final String userId;
  final CreateProjectParams project;
}

final class UpdateProjectRequest {
  const UpdateProjectRequest({required this.userId, required this.project});

  final String userId;
  final UpdateProjectParams project;
}
