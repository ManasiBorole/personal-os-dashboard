import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/services/database_service.dart';
import 'package:personal_os_dashboard/features/dashboard/data/datasources/dashboard_sample_data.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';

/// Loads dashboard data from Supabase with sample-data fallback.
abstract interface class DashboardRemoteDataSource {
  Future<DashboardSummary> fetchSummary({String? userName});
}

final class SupabaseDashboardRemoteDataSource
    implements DashboardRemoteDataSource {
  SupabaseDashboardRemoteDataSource(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<DashboardSummary> fetchSummary({String? userName}) async {
    if (!_databaseService.isAvailable) {
      return DashboardSampleData.build(userName: userName);
    }

    try {
      final results = await Future.wait([
        _fetchTasks(),
        _fetchGoals(),
        _fetchProjects(),
        _fetchMeetings(),
        _fetchCalendarEvents(),
        _fetchNotes(),
      ]);

      final tasks = results[0];
      final goals = results[1];
      final projects = results[2];
      final meetings = results[3];
      final calendarEvents = results[4];
      final notes = results[5];

      if (_isEmptyRemoteData(
        tasks: tasks,
        goals: goals,
        projects: projects,
        meetings: meetings,
        calendarEvents: calendarEvents,
        notes: notes,
      )) {
        return DashboardSampleData.build(userName: userName);
      }

      return _mapRemoteData(
        userName: userName,
        tasks: tasks,
        goals: goals,
        projects: projects,
        meetings: meetings,
        calendarEvents: calendarEvents,
        notes: notes,
      );
    } on Object {
      return DashboardSampleData.build(userName: userName);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTasks() => _safeSelect(
        ApiConstants.tasksTable,
        orderBy: 'updated_at',
        limit: 50,
      );

  Future<List<Map<String, dynamic>>> _fetchGoals() => _safeSelect(
        ApiConstants.goalsTable,
        orderBy: 'updated_at',
        limit: 10,
      );

  Future<List<Map<String, dynamic>>> _fetchProjects() => _safeSelect(
        ApiConstants.projectsTable,
        orderBy: 'updated_at',
        limit: 10,
      );

  Future<List<Map<String, dynamic>>> _fetchMeetings() => _safeSelect(
        ApiConstants.meetingsTable,
        orderBy: 'start_time',
        limit: 5,
      );

  Future<List<Map<String, dynamic>>> _fetchCalendarEvents() => _safeSelect(
        ApiConstants.calendarEventsTable,
        orderBy: 'start_time',
        limit: 6,
      );

  Future<List<Map<String, dynamic>>> _fetchNotes() => _safeSelect(
        ApiConstants.notesTable,
        orderBy: 'updated_at',
        limit: 5,
      );

  Future<List<Map<String, dynamic>>> _safeSelect(
    String table, {
    String? orderBy,
    int? limit,
  }) async {
    try {
      return await _databaseService.select(
        table: table,
        orderBy: orderBy,
        ascending: false,
        limit: limit,
      );
    } on Object {
      return const [];
    }
  }

  bool _isEmptyRemoteData({
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> projects,
    required List<Map<String, dynamic>> meetings,
    required List<Map<String, dynamic>> calendarEvents,
    required List<Map<String, dynamic>> notes,
  }) {
    return tasks.isEmpty &&
        goals.isEmpty &&
        projects.isEmpty &&
        meetings.isEmpty &&
        calendarEvents.isEmpty &&
        notes.isEmpty;
  }

  DashboardSummary _mapRemoteData({
    required String? userName,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> projects,
    required List<Map<String, dynamic>> meetings,
    required List<Map<String, dynamic>> calendarEvents,
    required List<Map<String, dynamic>> notes,
  }) {
    final sample = DashboardSampleData.build(userName: userName);
    final now = DateTime.now();

    final completed = tasks.where((t) => t['status'] == 'completed').length;
    final inProgress = tasks.where((t) => t['status'] == 'in_progress').length;
    final overdue = tasks.where((t) => t['status'] == 'overdue').length;
    final dueToday = tasks.where((t) {
      final due = _parseDate(t['due_date']);
      return due != null && _isSameDay(due, now);
    }).length;

    return DashboardSummary(
      todayOverview: TodayOverview(
        greeting: sample.todayOverview.greeting,
        date: now,
        completedTasks: completed,
        totalTasks: tasks.length,
        meetingsCount: meetings.where((m) {
          final start = _parseDate(m['start_time']);
          return start != null && _isSameDay(start, now);
        }).length,
        focusLabel: goals.isNotEmpty
            ? goals.first['title']?.toString() ?? sample.todayOverview.focusLabel
            : sample.todayOverview.focusLabel,
        productivityScore: tasks.isEmpty
            ? sample.todayOverview.productivityScore
            : ((completed / tasks.length) * 100).round(),
      ),
      taskSummary: TaskSummary(
        total: tasks.length,
        completed: completed,
        inProgress: inProgress,
        overdue: overdue,
        dueToday: dueToday,
        highPriority:
            tasks.where((t) => t['priority'] == 'high').length,
      ),
      goals: goals.isEmpty
          ? sample.goals
          : goals
              .map(
                (g) => GoalProgressItem(
                  id: g['id']?.toString() ?? '',
                  title: g['title']?.toString() ?? 'Untitled goal',
                  progress: _parseProgress(g['progress']),
                  deadline: _parseDate(g['deadline']),
                  status: g['status']?.toString() ?? 'Active',
                ),
              )
              .toList(),
      projects: projects.isEmpty
          ? sample.projects
          : projects
              .map(
                (p) => ProjectProgressItem(
                  id: p['id']?.toString() ?? '',
                  name: p['name']?.toString() ?? 'Untitled project',
                  progress: _parseProgress(p['progress']),
                  completedTasks: p['completed_tasks'] as int? ?? 0,
                  totalTasks: p['total_tasks'] as int? ?? 0,
                  status: p['status']?.toString() ?? 'Active',
                ),
              )
              .toList(),
      meetings: meetings.isEmpty
          ? sample.meetings
          : meetings
              .map(
                (m) => UpcomingMeetingItem(
                  id: m['id']?.toString() ?? '',
                  title: m['title']?.toString() ?? 'Meeting',
                  startTime: _parseDate(m['start_time']) ?? now,
                  durationMinutes: m['duration_minutes'] as int? ?? 30,
                  location: m['location']?.toString(),
                  attendeeCount: m['attendee_count'] as int? ?? 0,
                ),
              )
              .toList(),
      calendarEvents: calendarEvents.isEmpty
          ? sample.calendarEvents
          : calendarEvents
              .map(
                (e) => CalendarPreviewItem(
                  id: e['id']?.toString() ?? '',
                  title: e['title']?.toString() ?? 'Event',
                  startTime: _parseDate(e['start_time']) ?? now,
                  endTime: _parseDate(e['end_time']) ?? now.add(const Duration(hours: 1)),
                  isAllDay: e['is_all_day'] as bool? ?? false,
                  category: e['category']?.toString() ?? 'General',
                ),
              )
              .toList(),
      quickActions: sample.quickActions,
      notes: notes.isEmpty
          ? sample.notes
          : notes
              .map(
                (n) => RecentNoteItem(
                  id: n['id']?.toString() ?? '',
                  title: n['title']?.toString() ?? 'Untitled note',
                  preview: _previewText(n['content']?.toString()),
                  updatedAt: _parseDate(n['updated_at']) ?? now,
                  tags: (n['tags'] as List?)?.map((e) => e.toString()).toList() ??
                      const [],
                ),
              )
              .toList(),
      analytics: sample.analytics,
    );
  }

  double _parseProgress(dynamic value) {
    if (value is num) {
      final progress = value.toDouble();
      return progress > 1 ? progress / 100 : progress;
    }
    return 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _previewText(String? content) {
    if (content == null || content.isEmpty) return '';
    return content.length <= 80 ? content : '${content.substring(0, 80)}...';
  }
}
