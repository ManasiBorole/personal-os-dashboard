import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';

/// Data transfer object for project persistence.
final class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.status,
    required this.clientName,
    required this.clientEmail,
    required this.clientCompany,
    required this.clientPhone,
    required this.budgetAmount,
    required this.budgetCurrency,
    required this.budgetSpent,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String description;
  final String status;
  final String clientName;
  final String clientEmail;
  final String clientCompany;
  final String clientPhone;
  final double budgetAmount;
  final String budgetCurrency;
  final double budgetSpent;
  final DateTime? startDate;
  final DateTime? endDate;
  final double progress;
  final int completedTasks;
  final int totalTasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'planning',
      clientName: json['client_name']?.toString() ?? '',
      clientEmail: json['client_email']?.toString() ?? '',
      clientCompany: json['client_company']?.toString() ?? '',
      clientPhone: json['client_phone']?.toString() ?? '',
      budgetAmount: _toDouble(json['budget_amount']),
      budgetCurrency: json['budget_currency']?.toString() ?? 'USD',
      budgetSpent: _toDouble(json['budget_spent']),
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      progress: _parseProgress(json['progress']),
      completedTasks: json['completed_tasks'] as int? ?? 0,
      totalTasks: json['total_tasks'] as int? ?? 0,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    final now = DateTime.now().toIso8601String();
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'status': status,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_company': clientCompany,
      'client_phone': clientPhone,
      'budget_amount': budgetAmount,
      'budget_currency': budgetCurrency,
      'budget_spent': budgetSpent,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'progress': (progress * 100).round(),
      'completed_tasks': completedTasks,
      'total_tasks': totalTasks,
      'created_at': now,
      'updated_at': now,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'status': status,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_company': clientCompany,
      'client_phone': clientPhone,
      'budget_amount': budgetAmount,
      'budget_currency': budgetCurrency,
      'budget_spent': budgetSpent,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'progress': (progress * 100).round(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Project toEntity() {
    return Project(
      id: id,
      userId: userId,
      name: name,
      description: description,
      status: ProjectStatus.fromString(status),
      client: ClientDetails(
        name: clientName,
        email: clientEmail,
        company: clientCompany,
        phone: clientPhone,
      ),
      budget: ProjectBudget(
        amount: budgetAmount,
        currency: budgetCurrency,
        spent: budgetSpent,
      ),
      timeline: ProjectTimeline(startDate: startDate, endDate: endDate),
      progress: progress,
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static double _parseProgress(dynamic value) {
    if (value is num) {
      final p = value.toDouble();
      return p > 1 ? p / 100 : p;
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

final class ProjectMemberModel {
  const ProjectMemberModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String projectId;
  final String name;
  final String email;
  final String role;

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Member',
    );
  }

  ProjectMember toEntity() => ProjectMember(
        id: id,
        projectId: projectId,
        name: name,
        email: email,
        role: role,
      );
}

final class ProjectNoteModel {
  const ProjectNoteModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String title;
  final String content;
  final DateTime updatedAt;

  factory ProjectNoteModel.fromJson(Map<String, dynamic> json) {
    return ProjectNoteModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      updatedAt: ProjectModel._parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  ProjectNote toEntity() => ProjectNote(
        id: id,
        projectId: projectId,
        title: title,
        content: content,
        updatedAt: updatedAt,
      );
}

final class ProjectFileModel {
  const ProjectFileModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.storagePath,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploadedAt,
  });

  final String id;
  final String projectId;
  final String name;
  final String storagePath;
  final String mimeType;
  final int sizeBytes;
  final DateTime uploadedAt;

  factory ProjectFileModel.fromJson(Map<String, dynamic> json) {
    return ProjectFileModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      storagePath: json['storage_path']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? 'application/octet-stream',
      sizeBytes: json['size_bytes'] as int? ?? 0,
      uploadedAt: ProjectModel._parseDate(json['uploaded_at']) ?? DateTime.now(),
    );
  }

  ProjectFile toEntity() => ProjectFile(
        id: id,
        projectId: projectId,
        name: name,
        storagePath: storagePath,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
        uploadedAt: uploadedAt,
      );
}

final class ProjectTaskModel {
  const ProjectTaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.status,
    required this.priority,
    required this.dueDate,
  });

  final String id;
  final String projectId;
  final String title;
  final String status;
  final String priority;
  final DateTime? dueDate;

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      priority: json['priority']?.toString() ?? 'medium',
      dueDate: ProjectModel._parseDate(json['due_date']),
    );
  }

  ProjectTaskItem toEntity() => ProjectTaskItem(
        id: id,
        projectId: projectId,
        title: title,
        status: status,
        priority: priority,
        dueDate: dueDate,
      );
}
