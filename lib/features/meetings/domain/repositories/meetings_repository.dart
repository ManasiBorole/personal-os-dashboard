import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';

/// Meetings repository contract.
abstract interface class MeetingsRepository {
  Future<List<Meeting>> getMeetings({required String userId});

  Future<Meeting> getMeetingById({required String id});

  Future<Meeting> createMeeting({
    required String userId,
    required CreateMeetingParams params,
  });

  Future<Meeting> updateMeeting({
    required String userId,
    required UpdateMeetingParams params,
  });

  Future<void> deleteMeeting({required String id});
}
