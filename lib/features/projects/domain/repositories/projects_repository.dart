import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';

/// Contract for project persistence and dashboard aggregation.
abstract interface class ProjectsRepository {
  Future<List<Project>> getProjects({required String userId});

  Future<Project> getProjectById({required String id});

  Future<ProjectDashboard> getProjectDashboard({required String projectId});

  Future<Project> createProject({
    required String userId,
    required CreateProjectParams params,
  });

  Future<Project> updateProject({
    required String userId,
    required UpdateProjectParams params,
  });

  Future<void> deleteProject({required String id});

  Future<ProjectMember> addMember({
    required String projectId,
    required String name,
    required String email,
    required String role,
  });

  Future<void> removeMember({required String memberId});

  Future<ProjectNote> addNote({
    required String projectId,
    required String title,
    required String content,
  });

  Future<void> deleteNote({required String noteId});
}
