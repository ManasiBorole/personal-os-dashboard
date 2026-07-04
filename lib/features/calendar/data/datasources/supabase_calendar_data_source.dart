import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/features/calendar/data/datasources/calendar_data_source.dart';
import 'package:personal_os_dashboard/features/calendar/data/models/calendar_event_model.dart';
import 'package:personal_os_dashboard/features/calendar/domain/entities/calendar_event_params.dart';

final class SupabaseCalendarDataSource implements CalendarDataSource {
  SupabaseCalendarDataSource(this._database);

  final DatabaseRemoteDataSource _database;

  @override
  Future<List<CalendarEventModel>> getEvents({
    required String userId,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final rows = await _database.select(
      table: ApiConstants.calendarEventsTable,
      filters: {'user_id': userId},
      orderBy: 'start_time',
      ascending: true,
    );

    return rows
        .map(CalendarEventModel.fromJson)
        .where(
          (e) =>
              e.startTime.isBefore(rangeEnd) && e.endTime.isAfter(rangeStart),
        )
        .toList();
  }

  @override
  Future<CalendarEventModel> getEventById({required String id}) async {
    final row = await _database.selectById(
      table: ApiConstants.calendarEventsTable,
      id: id,
    );
    return CalendarEventModel.fromJson(row);
  }

  @override
  Future<CalendarEventModel> createEvent({
    required String userId,
    required CreateCalendarEventParams params,
  }) async {
    final row = await _database.insert(
      table: ApiConstants.calendarEventsTable,
      data: {
        'user_id': userId,
        'title': params.title.trim(),
        'description': params.description.trim(),
        'event_type': params.eventType,
        'start_time': params.startTime.toIso8601String(),
        'end_time': params.endTime.toIso8601String(),
        'is_all_day': params.isAllDay,
        'location': params.location,
        'reminder_at': params.reminderAt?.toIso8601String(),
        'attendee_count': params.attendeeCount,
        'linked_task_id': params.linkedTaskId,
      },
    );

    if (params.eventType == 'meeting') {
      await _syncMeeting(userId: userId, row: row, isCreate: true);
    }

    return CalendarEventModel.fromJson(row);
  }

  @override
  Future<CalendarEventModel> updateEvent({
    required String userId,
    required UpdateCalendarEventParams params,
  }) async {
    final row = await _database.update(
      table: ApiConstants.calendarEventsTable,
      data: {
        'title': params.title.trim(),
        'description': params.description.trim(),
        'event_type': params.eventType,
        'start_time': params.startTime.toIso8601String(),
        'end_time': params.endTime.toIso8601String(),
        'is_all_day': params.isAllDay,
        'location': params.clearLocation ? null : params.location,
        'reminder_at':
            params.clearReminder ? null : params.reminderAt?.toIso8601String(),
        'attendee_count': params.attendeeCount,
        'linked_task_id':
            params.clearLinkedTaskId ? null : params.linkedTaskId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': params.id, 'user_id': userId},
    );

    if (params.eventType == 'meeting') {
      await _syncMeeting(userId: userId, row: row, isCreate: false);
    }

    return CalendarEventModel.fromJson(row);
  }

  @override
  Future<void> deleteEvent({required String id}) async {
    await _database.delete(
      table: ApiConstants.calendarEventsTable,
      filters: {'id': id},
    );
  }

  Future<void> _syncMeeting({
    required String userId,
    required Map<String, dynamic> row,
    required bool isCreate,
  }) async {
    final event = CalendarEventModel.fromJson(row);
    final data = {
      'user_id': userId,
      'title': event.title,
      'start_time': event.startTime.toIso8601String(),
      'duration_minutes': event.endTime.difference(event.startTime).inMinutes,
      'location': event.location,
      'attendee_count': event.attendeeCount,
      'agenda': event.description,
    };

    if (isCreate) {
      await _database.insert(
        table: ApiConstants.meetingsTable,
        data: data,
      );
    } else {
      try {
        await _database.update(
          table: ApiConstants.meetingsTable,
          data: data,
          filters: {'id': event.id},
        );
      } on Object {
        await _database.insert(
          table: ApiConstants.meetingsTable,
          data: {...data, 'id': event.id},
        );
      }
    }
  }
}
