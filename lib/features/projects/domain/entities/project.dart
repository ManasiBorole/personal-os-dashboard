import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// Project lifecycle status.
enum ProjectStatus {
  planning('Planning'),
  active('Active'),
  onHold('On Hold'),
  completed('Completed'),
  cancelled('Cancelled');

  const ProjectStatus(this.label);

  final String label;

  static ProjectStatus fromString(String? value) {
    return ProjectStatus.values.firstWhere(
      (status) =>
          status.name == value?.toLowerCase().replaceAll(' ', '_') ||
          status.label.toLowerCase() == value?.toLowerCase(),
      orElse: () => ProjectStatus.planning,
    );
  }
}

/// Client contact information for a project.
final class ClientDetails extends Entity {
  const ClientDetails({
    required this.name,
    required this.email,
    required this.company,
    required this.phone,
  });

  final String name;
  final String email;
  final String company;
  final String phone;

  bool get isEmpty =>
      name.isEmpty && email.isEmpty && company.isEmpty && phone.isEmpty;

  @override
  List<Object?> get props => [name, email, company, phone];
}

/// Budget tracking for a project.
final class ProjectBudget extends Entity {
  const ProjectBudget({
    required this.amount,
    required this.currency,
    required this.spent,
  });

  final double amount;
  final String currency;
  final double spent;

  double get remaining => (amount - spent).clamp(0, amount);

  double get utilization => amount == 0 ? 0 : (spent / amount).clamp(0, 1);

  @override
  List<Object?> get props => [amount, currency, spent];
}

/// Timeline window for a project.
final class ProjectTimeline extends Entity {
  const ProjectTimeline({
    required this.startDate,
    required this.endDate,
  });

  final DateTime? startDate;
  final DateTime? endDate;

  int? get durationDays {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays;
  }

  double? get elapsedPercent {
    if (startDate == null || endDate == null) return null;
    final now = DateTime.now();
    if (now.isBefore(startDate!)) return 0;
    if (now.isAfter(endDate!)) return 1;
    final total = endDate!.difference(startDate!).inMilliseconds;
    if (total == 0) return 1;
    return now.difference(startDate!).inMilliseconds / total;
  }

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Core project entity.
final class Project extends Entity {
  const Project({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.status,
    required this.client,
    required this.budget,
    required this.timeline,
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
  final ProjectStatus status;
  final ClientDetails client;
  final ProjectBudget budget;
  final ProjectTimeline timeline;
  final double progress;
  final int completedTasks;
  final int totalTasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get progressPercent => (progress * 100).round();

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        status,
        client,
        budget,
        timeline,
        progress,
        completedTasks,
        totalTasks,
        createdAt,
        updatedAt,
      ];
}

/// Team member assigned to a project.
final class ProjectMember extends Entity {
  const ProjectMember({
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

  @override
  List<Object?> get props => [id, projectId, name, email, role];
}

/// Task summary linked to a project.
final class ProjectTaskItem extends Entity {
  const ProjectTaskItem({
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

  @override
  List<Object?> get props => [id, projectId, title, status, priority, dueDate];
}

/// File metadata linked to a project.
final class ProjectFile extends Entity {
  const ProjectFile({
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

  @override
  List<Object?> get props =>
      [id, projectId, name, storagePath, mimeType, sizeBytes, uploadedAt];
}

/// Note attached to a project.
final class ProjectNote extends Entity {
  const ProjectNote({
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

  @override
  List<Object?> get props => [id, projectId, title, content, updatedAt];
}

/// Aggregated project dashboard data.
final class ProjectDashboard extends Entity {
  const ProjectDashboard({
    required this.project,
    required this.members,
    required this.tasks,
    required this.files,
    required this.notes,
  });

  final Project project;
  final List<ProjectMember> members;
  final List<ProjectTaskItem> tasks;
  final List<ProjectFile> files;
  final List<ProjectNote> notes;

  @override
  List<Object?> get props => [project, members, tasks, files, notes];
}
