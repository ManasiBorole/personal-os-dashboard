import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';

/// Parameters for creating a meeting.
final class CreateMeetingParams {
  const CreateMeetingParams({
    required this.title,
    required this.agenda,
    required this.participants,
    required this.startTime,
    required this.durationMinutes,
    required this.location,
    required this.notes,
    required this.followUp,
    required this.attachments,
    required this.reminderAt,
    required this.status,
  });

  final String title;
  final String agenda;
  final List<MeetingParticipant> participants;
  final DateTime startTime;
  final int durationMinutes;
  final String? location;
  final String notes;
  final String followUp;
  final List<MeetingAttachment> attachments;
  final DateTime? reminderAt;
  final String status;
}

/// Parameters for updating a meeting.
final class UpdateMeetingParams {
  const UpdateMeetingParams({
    required this.id,
    required this.title,
    required this.agenda,
    required this.participants,
    required this.startTime,
    required this.durationMinutes,
    required this.location,
    required this.notes,
    required this.followUp,
    required this.attachments,
    required this.reminderAt,
    required this.status,
    this.clearLocation = false,
    this.clearReminder = false,
  });

  final String id;
  final String title;
  final String agenda;
  final List<MeetingParticipant> participants;
  final DateTime startTime;
  final int durationMinutes;
  final String? location;
  final String notes;
  final String followUp;
  final List<MeetingAttachment> attachments;
  final DateTime? reminderAt;
  final String status;
  final bool clearLocation;
  final bool clearReminder;
}

/// Filter for meetings list.
enum MeetingListTab {
  upcoming('Upcoming'),
  history('History');

  const MeetingListTab(this.label);

  final String label;
}

final class MeetingFilter {
  const MeetingFilter({
    this.tab = MeetingListTab.upcoming,
    this.status,
  });

  final MeetingListTab tab;
  final MeetingStatus? status;

  static const MeetingFilter empty = MeetingFilter();

  MeetingFilter copyWith({
    MeetingListTab? tab,
    MeetingStatus? status,
    bool clearStatus = false,
  }) {
    return MeetingFilter(
      tab: tab ?? this.tab,
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

enum MeetingSortOption {
  startTimeAsc('Start time (soonest)'),
  startTimeDesc('Start time (latest)'),
  recentlyUpdated('Recently updated'),
  titleAsc('Title (A–Z)');

  const MeetingSortOption(this.label);

  final String label;
}
