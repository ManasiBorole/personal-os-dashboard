import 'package:personal_os_dashboard/features/projects/domain/entities/project.dart';

/// Parameters for creating a project.
final class CreateProjectParams {
  const CreateProjectParams({
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
  });

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
}

/// Parameters for updating a project.
final class UpdateProjectParams {
  const UpdateProjectParams({
    required this.id,
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
    this.clearStartDate = false,
    this.clearEndDate = false,
  });

  final String id;
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
  final bool clearStartDate;
  final bool clearEndDate;
}

/// Filter criteria for projects list.
final class ProjectFilter {
  const ProjectFilter({this.status});

  final ProjectStatus? status;

  static const ProjectFilter empty = ProjectFilter();

  ProjectFilter copyWith({ProjectStatus? status, bool clearStatus = false}) {
    return ProjectFilter(
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  bool get hasActiveFilters => status != null;
}

/// Sort options for projects list.
enum ProjectSortOption {
  recentlyUpdated('Recently updated'),
  nameAsc('Name (A–Z)'),
  nameDesc('Name (Z–A)'),
  progressDesc('Progress (high–low)'),
  deadlineAsc('End date (soonest)'),
  budgetDesc('Budget (high–low)');

  const ProjectSortOption(this.label);

  final String label;
}
