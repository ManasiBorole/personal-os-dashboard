import 'package:personal_os_dashboard/features/projects/data/models/project_model.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';

/// Contract for project data persistence.
abstract interface class ProjectsDataSource {
  Future<List<ProjectModel>> getProjects({required String userId});

  Future<ProjectModel> getProjectById({required String id});

  Future<ProjectModel> createProject({
    required String userId,
    required CreateProjectParams params,
  });

  Future<ProjectModel> updateProject({
    required String userId,
    required UpdateProjectParams params,
  });

  Future<void> deleteProject({required String id});

  Future<List<ProjectMemberModel>> getMembers({required String projectId});

  Future<List<ProjectTaskModel>> getTasks({required String projectId});

  Future<List<ProjectFileModel>> getFiles({required String projectId});

  Future<List<ProjectNoteModel>> getNotes({required String projectId});

  Future<ProjectMemberModel> addMember({
    required String projectId,
    required String name,
    required String email,
    required String role,
  });

  Future<void> removeMember({required String memberId});

  Future<ProjectNoteModel> addNote({
    required String projectId,
    required String title,
    required String content,
  });

  Future<void> deleteNote({required String noteId});
}
