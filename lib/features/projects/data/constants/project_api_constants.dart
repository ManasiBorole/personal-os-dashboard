import 'package:personal_os_dashboard/core/constants/api_constants.dart';

/// Supabase table identifiers for project management.
abstract final class ProjectApiConstants {
  static const String projectsTable = ApiConstants.projectsTable;
  static const String membersTable = 'project_members';
  static const String notesTable = 'project_notes';
  static const String filesTable = 'project_files';
  static const String tasksTable = ApiConstants.tasksTable;
}
