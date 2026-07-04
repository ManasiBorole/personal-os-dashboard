import 'package:personal_os_dashboard/features/meetings/data/models/meeting_model.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';

/// Data source contract for meetings.
abstract interface class MeetingsDataSource {
  Future<List<MeetingModel>> getMeetings({required String userId});

  Future<MeetingModel> getMeetingById({required String id});

  Future<MeetingModel> createMeeting({
    required String userId,
    required CreateMeetingParams params,
  });

  Future<MeetingModel> updateMeeting({
    required String userId,
    required UpdateMeetingParams params,
  });

  Future<void> deleteMeeting({required String id});
}
