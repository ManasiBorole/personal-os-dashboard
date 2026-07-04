import 'package:personal_os_dashboard/features/projects/data/datasources/local_projects_data_source.dart';
import 'package:personal_os_dashboard/features/projects/data/datasources/projects_data_source.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';
import 'package:personal_os_dashboard/features/projects/domain/repositories/projects_repository.dart';

/// Repository implementation delegating to [ProjectsDataSource].
final class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl(this._dataSource);

  final ProjectsDataSource _dataSource;

  @override
  Future<List<Project>> getProjects({required String userId}) async {
    final models = await _dataSource.getProjects(userId: userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Project> getProjectById({required String id}) async {
    return (await _dataSource.getProjectById(id: id)).toEntity();
  }

  @override
  Future<ProjectDashboard> getProjectDashboard({
    required String projectId,
  }) async {
    final project = await getProjectById(id: projectId);
    final members = await _dataSource.getMembers(projectId: projectId);
    final tasks = await _dataSource.getTasks(projectId: projectId);
    final files = await _dataSource.getFiles(projectId: projectId);
    final notes = await _dataSource.getNotes(projectId: projectId);

    return ProjectDashboard(
      project: project,
      members: members.map((m) => m.toEntity()).toList(),
      tasks: tasks.map((t) => t.toEntity()).toList(),
      files: files.map((f) => f.toEntity()).toList(),
      notes: notes.map((n) => n.toEntity()).toList(),
    );
  }

  @override
  Future<Project> createProject({
    required String userId,
    required CreateProjectParams params,
  }) async {
    return (await _dataSource.createProject(userId: userId, params: params))
        .toEntity();
  }

  @override
  Future<Project> updateProject({
    required String userId,
    required UpdateProjectParams params,
  }) async {
    return (await _dataSource.updateProject(userId: userId, params: params))
        .toEntity();
  }

  @override
  Future<void> deleteProject({required String id}) async {
    await _dataSource.deleteProject(id: id);
  }

  @override
  Future<ProjectMember> addMember({
    required String projectId,
    required String name,
    required String email,
    required String role,
  }) async {
    return (await _dataSource.addMember(
      projectId: projectId,
      name: name,
      email: email,
      role: role,
    ))
        .toEntity();
  }

  @override
  Future<void> removeMember({required String memberId}) async {
    await _dataSource.removeMember(memberId: memberId);
  }

  @override
  Future<ProjectNote> addNote({
    required String projectId,
    required String title,
    required String content,
  }) async {
    return (await _dataSource.addNote(
      projectId: projectId,
      title: title,
      content: content,
    ))
        .toEntity();
  }

  @override
  Future<void> deleteNote({required String noteId}) async {
    await _dataSource.deleteNote(noteId: noteId);
  }
}

/// Fallback repository backed by in-memory local storage.
final class UnconfiguredProjectsRepository implements ProjectsRepository {
  UnconfiguredProjectsRepository()
      : _delegate = ProjectsRepositoryImpl(LocalProjectsDataSource());

  final ProjectsRepositoryImpl _delegate;

  @override
  Future<List<Project>> getProjects({required String userId}) =>
      _delegate.getProjects(userId: userId);

  @override
  Future<Project> getProjectById({required String id}) =>
      _delegate.getProjectById(id: id);

  @override
  Future<ProjectDashboard> getProjectDashboard({required String projectId}) =>
      _delegate.getProjectDashboard(projectId: projectId);

  @override
  Future<Project> createProject({
    required String userId,
    required CreateProjectParams params,
  }) =>
      _delegate.createProject(userId: userId, params: params);

  @override
  Future<Project> updateProject({
    required String userId,
    required UpdateProjectParams params,
  }) =>
      _delegate.updateProject(userId: userId, params: params);

  @override
  Future<void> deleteProject({required String id}) =>
      _delegate.deleteProject(id: id);

  @override
  Future<ProjectMember> addMember({
    required String projectId,
    required String name,
    required String email,
    required String role,
  }) =>
      _delegate.addMember(
        projectId: projectId,
        name: name,
        email: email,
        role: role,
      );

  @override
  Future<void> removeMember({required String memberId}) =>
      _delegate.removeMember(memberId: memberId);

  @override
  Future<ProjectNote> addNote({
    required String projectId,
    required String title,
    required String content,
  }) =>
      _delegate.addNote(
        projectId: projectId,
        title: title,
        content: content,
      );

  @override
  Future<void> deleteNote({required String noteId}) =>
      _delegate.deleteNote(noteId: noteId);
}

ProjectsRepository createProjectsRepository({
  required bool isSupabaseReady,
  required ProjectsDataSource remoteDataSource,
}) {
  if (isSupabaseReady) {
    return ProjectsRepositoryImpl(remoteDataSource);
  }
  return UnconfiguredProjectsRepository();
}
