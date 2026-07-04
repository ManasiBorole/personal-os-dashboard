import 'package:personal_os_dashboard/features/projects/data/datasources/projects_data_source.dart';
import 'package:personal_os_dashboard/features/projects/data/models/project_model.dart';
import 'package:personal_os_dashboard/features/projects/domain/entities/project_params.dart';

/// In-memory projects storage for offline/unconfigured environments.
final class LocalProjectsDataSource implements ProjectsDataSource {
  final Map<String, ProjectModel> _projects = {};
  final Map<String, ProjectMemberModel> _members = {};
  final Map<String, ProjectNoteModel> _notes = {};
  final Map<String, ProjectFileModel> _files = {};
  final Map<String, ProjectTaskModel> _tasks = {};

  LocalProjectsDataSource() {
    _seed();
  }

  void _seed() {
    const userId = 'local-user';
    final now = DateTime.now();

    final project1 = ProjectModel(
      id: 'proj-local-1',
      userId: userId,
      name: 'Personal OS Dashboard',
      description: 'Enterprise Flutter productivity platform with Supabase backend.',
      status: 'active',
      clientName: 'Acme Corp',
      clientEmail: 'contact@acme.com',
      clientCompany: 'Acme Corporation',
      clientPhone: '+1 555-0100',
      budgetAmount: 120000,
      budgetCurrency: 'USD',
      budgetSpent: 78000,
      startDate: now.subtract(const Duration(days: 60)),
      endDate: now.add(const Duration(days: 90)),
      progress: 0.65,
      completedTasks: 26,
      totalTasks: 40,
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now.subtract(const Duration(hours: 3)),
    );

    final project2 = ProjectModel(
      id: 'proj-local-2',
      userId: userId,
      name: 'Marketing Website Redesign',
      description: 'Modern marketing site with CMS integration.',
      status: 'planning',
      clientName: 'Jane Smith',
      clientEmail: 'jane@startup.io',
      clientCompany: 'Startup.io',
      clientPhone: '+1 555-0200',
      budgetAmount: 45000,
      budgetCurrency: 'USD',
      budgetSpent: 12000,
      startDate: now.add(const Duration(days: 14)),
      endDate: now.add(const Duration(days: 120)),
      progress: 0.35,
      completedTasks: 7,
      totalTasks: 20,
      createdAt: now.subtract(const Duration(days: 20)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );

    _projects[project1.id] = project1;
    _projects[project2.id] = project2;

    _members['mem-1'] = ProjectMemberModel(
      id: 'mem-1',
      projectId: project1.id,
      name: 'Alex Johnson',
      email: 'alex@acme.com',
      role: 'Project Lead',
    );
    _members['mem-2'] = ProjectMemberModel(
      id: 'mem-2',
      projectId: project1.id,
      name: 'Sam Rivera',
      email: 'sam@acme.com',
      role: 'Developer',
    );

    _tasks['task-1'] = ProjectTaskModel(
      id: 'task-1',
      projectId: project1.id,
      title: 'Implement auth module',
      status: 'completed',
      priority: 'high',
      dueDate: now.subtract(const Duration(days: 10)),
    );
    _tasks['task-2'] = ProjectTaskModel(
      id: 'task-2',
      projectId: project1.id,
      title: 'Build project management',
      status: 'in_progress',
      priority: 'high',
      dueDate: now.add(const Duration(days: 7)),
    );
    _tasks['task-3'] = ProjectTaskModel(
      id: 'task-3',
      projectId: project1.id,
      title: 'Write API documentation',
      status: 'pending',
      priority: 'medium',
      dueDate: now.add(const Duration(days: 21)),
    );

    _files['file-1'] = ProjectFileModel(
      id: 'file-1',
      projectId: project1.id,
      name: 'Project Brief.pdf',
      storagePath: 'projects/proj-local-1/brief.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 245760,
      uploadedAt: now.subtract(const Duration(days: 30)),
    );
    _files['file-2'] = ProjectFileModel(
      id: 'file-2',
      projectId: project1.id,
      name: 'Wireframes.fig',
      storagePath: 'projects/proj-local-1/wireframes.fig',
      mimeType: 'application/octet-stream',
      sizeBytes: 1048576,
      uploadedAt: now.subtract(const Duration(days: 25)),
    );

    _notes['note-1'] = ProjectNoteModel(
      id: 'note-1',
      projectId: project1.id,
      title: 'Sprint planning notes',
      content: 'Focus on core modules: auth, dashboard, goals, projects.',
      updatedAt: now.subtract(const Duration(hours: 5)),
    );
  }

  @override
  Future<List<ProjectModel>> getProjects({required String userId}) async {
    return _projects.values
        .where((p) => p.userId == userId || p.userId == 'local-user')
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<ProjectModel> getProjectById({required String id}) async {
    final project = _projects[id];
    if (project == null) throw StateError('Project not found');
    return project;
  }

  @override
  Future<ProjectModel> createProject({
    required String userId,
    required CreateProjectParams params,
  }) async {
    final now = DateTime.now();
    final id = 'proj-local-${now.microsecondsSinceEpoch}';
    final project = ProjectModel(
      id: id,
      userId: userId,
      name: params.name.trim(),
      description: params.description.trim(),
      status: params.status,
      clientName: params.clientName.trim(),
      clientEmail: params.clientEmail.trim(),
      clientCompany: params.clientCompany.trim(),
      clientPhone: params.clientPhone.trim(),
      budgetAmount: params.budgetAmount,
      budgetCurrency: params.budgetCurrency,
      budgetSpent: params.budgetSpent,
      startDate: params.startDate,
      endDate: params.endDate,
      progress: params.progress,
      completedTasks: 0,
      totalTasks: 0,
      createdAt: now,
      updatedAt: now,
    );
    _projects[id] = project;
    return project;
  }

  @override
  Future<ProjectModel> updateProject({
    required String userId,
    required UpdateProjectParams params,
  }) async {
    final existing = await getProjectById(id: params.id);
    final updated = ProjectModel(
      id: existing.id,
      userId: userId,
      name: params.name.trim(),
      description: params.description.trim(),
      status: params.status,
      clientName: params.clientName.trim(),
      clientEmail: params.clientEmail.trim(),
      clientCompany: params.clientCompany.trim(),
      clientPhone: params.clientPhone.trim(),
      budgetAmount: params.budgetAmount,
      budgetCurrency: params.budgetCurrency,
      budgetSpent: params.budgetSpent,
      startDate: params.clearStartDate ? null : params.startDate,
      endDate: params.clearEndDate ? null : params.endDate,
      progress: params.progress,
      completedTasks: existing.completedTasks,
      totalTasks: existing.totalTasks,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _projects[updated.id] = updated;
    return updated;
  }

  @override
  Future<void> deleteProject({required String id}) async {
    _projects.remove(id);
    _members.removeWhere((_, m) => m.projectId == id);
    _notes.removeWhere((_, n) => n.projectId == id);
    _files.removeWhere((_, f) => f.projectId == id);
    _tasks.removeWhere((_, t) => t.projectId == id);
  }

  @override
  Future<List<ProjectMemberModel>> getMembers({required String projectId}) async {
    return _members.values.where((m) => m.projectId == projectId).toList();
  }

  @override
  Future<List<ProjectTaskModel>> getTasks({required String projectId}) async {
    return _tasks.values.where((t) => t.projectId == projectId).toList();
  }

  @override
  Future<List<ProjectFileModel>> getFiles({required String projectId}) async {
    return _files.values.where((f) => f.projectId == projectId).toList();
  }

  @override
  Future<List<ProjectNoteModel>> getNotes({required String projectId}) async {
    return _notes.values.where((n) => n.projectId == projectId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<ProjectMemberModel> addMember({
    required String projectId,
    required String name,
    required String email,
    required String role,
  }) async {
    final id = 'mem-${DateTime.now().microsecondsSinceEpoch}';
    final member = ProjectMemberModel(
      id: id,
      projectId: projectId,
      name: name.trim(),
      email: email.trim(),
      role: role.trim(),
    );
    _members[id] = member;
    return member;
  }

  @override
  Future<void> removeMember({required String memberId}) async {
    _members.remove(memberId);
  }

  @override
  Future<ProjectNoteModel> addNote({
    required String projectId,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final id = 'note-${now.microsecondsSinceEpoch}';
    final note = ProjectNoteModel(
      id: id,
      projectId: projectId,
      title: title.trim(),
      content: content.trim(),
      updatedAt: now,
    );
    _notes[id] = note;
    return note;
  }

  @override
  Future<void> deleteNote({required String noteId}) async {
    _notes.remove(noteId);
  }
}
