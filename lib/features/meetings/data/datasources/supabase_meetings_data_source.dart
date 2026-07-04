import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/features/meetings/data/datasources/meetings_data_source.dart';
import 'package:personal_os_dashboard/features/meetings/data/models/meeting_model.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';

final class SupabaseMeetingsDataSource implements MeetingsDataSource {
  SupabaseMeetingsDataSource(this._database);

  final DatabaseRemoteDataSource _database;

  @override
  Future<List<MeetingModel>> getMeetings({required String userId}) async {
    final rows = await _database.select(
      table: ApiConstants.meetingsTable,
      filters: {'user_id': userId},
      orderBy: 'start_time',
      ascending: false,
    );
    return rows.map(MeetingModel.fromJson).toList();
  }

  @override
  Future<MeetingModel> getMeetingById({required String id}) async {
    final row = await _database.selectById(
      table: ApiConstants.meetingsTable,
      id: id,
    );
    return MeetingModel.fromJson(row);
  }

  @override
  Future<MeetingModel> createMeeting({
    required String userId,
    required CreateMeetingParams params,
  }) async {
    final row = await _database.insert(
      table: ApiConstants.meetingsTable,
      data: {
        'user_id': userId,
        'title': params.title.trim(),
        'agenda': params.agenda.trim(),
        'participants': params.participants
            .map(MeetingModel.participantToJson)
            .toList(),
        'start_time': params.startTime.toIso8601String(),
        'duration_minutes': params.durationMinutes,
        'location': params.location,
        'attendee_count': params.participants.length,
        'notes': params.notes.trim(),
        'follow_up': params.followUp.trim(),
        'attachments': params.attachments
            .map(MeetingModel.attachmentToJson)
            .toList(),
        'reminder_at': params.reminderAt?.toIso8601String(),
        'status': params.status,
      },
    );
    return MeetingModel.fromJson(row);
  }

  @override
  Future<MeetingModel> updateMeeting({
    required String userId,
    required UpdateMeetingParams params,
  }) async {
    final row = await _database.update(
      table: ApiConstants.meetingsTable,
      data: {
        'title': params.title.trim(),
        'agenda': params.agenda.trim(),
        'participants': params.participants
            .map(MeetingModel.participantToJson)
            .toList(),
        'start_time': params.startTime.toIso8601String(),
        'duration_minutes': params.durationMinutes,
        'location': params.clearLocation ? null : params.location,
        'attendee_count': params.participants.length,
        'notes': params.notes.trim(),
        'follow_up': params.followUp.trim(),
        'attachments': params.attachments
            .map(MeetingModel.attachmentToJson)
            .toList(),
        'reminder_at':
            params.clearReminder ? null : params.reminderAt?.toIso8601String(),
        'status': params.status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': params.id, 'user_id': userId},
    );
    return MeetingModel.fromJson(row);
  }

  @override
  Future<void> deleteMeeting({required String id}) async {
    await _database.delete(
      table: ApiConstants.meetingsTable,
      filters: {'id': id},
    );
  }
}
