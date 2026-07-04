import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/features/projects/data/constants/project_api_constants.dart';
import 'package:personal_os_dashboard/features/projects/data/datasources/projects_data_source.dart';
import 'package:personal_os_dashboard/features/projects/data/models/project_model.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';

/// Supabase-backed projects data source.
final class SupabaseProjectsDataSource implements ProjectsDataSource {
  SupabaseProjectsDataSource(this._database);

  final DatabaseRemoteDataSource _database;

  @override
  Future<List<ProjectModel>> getProjects({required String userId}) async {
    final rows = await _database.select(
      table: ProjectApiConstants.projectsTable,
      filters: {'user_id': userId},
      orderBy: 'updated_at',
      ascending: false,
    );
    return rows.map(ProjectModel.fromJson).toList();
  }

  @override
  Future<ProjectModel> getProjectById({required String id}) async {
    final row = await _database.selectById(
      table: ProjectApiConstants.projectsTable,
      id: id,
    );
    return ProjectModel.fromJson(row);
  }

  @override
  Future<ProjectModel> createProject({
    required String userId,
    required CreateProjectParams params,
  }) async {
    final row = await _database.insert(
      table: ProjectApiConstants.projectsTable,
      data: {
        'user_id': userId,
        'name': params.name.trim(),
        'description': params.description.trim(),
        'status': params.status,
        'client_name': params.clientName.trim(),
        'client_email': params.clientEmail.trim(),
        'client_company': params.clientCompany.trim(),
        'client_phone': params.clientPhone.trim(),
        'budget_amount': params.budgetAmount,
        'budget_currency': params.budgetCurrency,
        'budget_spent': params.budgetSpent,
        'start_date': params.startDate?.toIso8601String(),
        'end_date': params.endDate?.toIso8601String(),
        'progress': (params.progress * 100).round(),
        'completed_tasks': 0,
        'total_tasks': 0,
      },
    );
    return ProjectModel.fromJson(row);
  }

  @override
  Future<ProjectModel> updateProject({
    required String userId,
    required UpdateProjectParams params,
  }) async {
    final row = await _database.update(
      table: ProjectApiConstants.projectsTable,
      data: {
        'name': params.name.trim(),
        'description': params.description.trim(),
        'status': params.status,
        'client_name': params.clientName.trim(),
        'client_email': params.clientEmail.trim(),
        'client_company': params.clientCompany.trim(),
        'client_phone': params.clientPhone.trim(),
        'budget_amount': params.budgetAmount,
        'budget_currency': params.budgetCurrency,
        'budget_spent': params.budgetSpent,
        'start_date':
            params.clearStartDate ? null : params.startDate?.toIso8601String(),
        'end_date':
            params.clearEndDate ? null : params.endDate?.toIso8601String(),
        'progress': (params.progress * 100).round(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': params.id, 'user_id': userId},
    );
    return ProjectModel.fromJson(row);
  }

  @override
  Future<void> deleteProject({required String id}) async {
    await _database.delete(
      table: ProjectApiConstants.projectsTable,
      filters: {'id': id},
    );
  }

  @override
  Future<List<ProjectMemberModel>> getMembers({
    required String projectId,
  }) async {
    final rows = await _safeSelect(
      ProjectApiConstants.membersTable,
      {'project_id': projectId},
    );
    return rows.map(ProjectMemberModel.fromJson).toList();
  }

  @override
  Future<List<ProjectTaskModel>> getTasks({required String projectId}) async {
    final rows = await _safeSelect(
      ProjectApiConstants.tasksTable,
      {'project_id': projectId},
      orderBy: 'due_date',
    );
    return rows.map(ProjectTaskModel.fromJson).toList();
  }

  @override
  Future<List<ProjectFileModel>> getFiles({required String projectId}) async {
    final rows = await _safeSelect(
      ProjectApiConstants.filesTable,
      {'project_id': projectId},
      orderBy: 'uploaded_at',
    );
    return rows.map(ProjectFileModel.fromJson).toList();
  }

  @override
  Future<List<ProjectNoteModel>> getNotes({required String projectId}) async {
    final rows = await _safeSelect(
      ProjectApiConstants.notesTable,
      {'project_id': projectId},
      orderBy: 'updated_at',
    );
    return rows.map(ProjectNoteModel.fromJson).toList();
  }

  @override
  Future<ProjectMemberModel> addMember({
    required String projectId,
    required String name,
    required String email,
    required String role,
  }) async {
    final row = await _database.insert(
      table: ProjectApiConstants.membersTable,
      data: {
        'project_id': projectId,
        'name': name.trim(),
        'email': email.trim(),
        'role': role.trim(),
      },
    );
    return ProjectMemberModel.fromJson(row);
  }

  @override
  Future<void> removeMember({required String memberId}) async {
    await _database.delete(
      table: ProjectApiConstants.membersTable,
      filters: {'id': memberId},
    );
  }

  @override
  Future<ProjectNoteModel> addNote({
    required String projectId,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now().toIso8601String();
    final row = await _database.insert(
      table: ProjectApiConstants.notesTable,
      data: {
        'project_id': projectId,
        'title': title.trim(),
        'content': content.trim(),
        'created_at': now,
        'updated_at': now,
      },
    );
    return ProjectNoteModel.fromJson(row);
  }

  @override
  Future<void> deleteNote({required String noteId}) async {
    await _database.delete(
      table: ProjectApiConstants.notesTable,
      filters: {'id': noteId},
    );
  }

  Future<List<Map<String, dynamic>>> _safeSelect(
    String table,
    Map<String, dynamic> filters, {
    String? orderBy,
  }) async {
    try {
      return await _database.select(
        table: table,
        filters: filters,
        orderBy: orderBy,
        ascending: false,
      );
    } on Object {
      return const [];
    }
  }
}
