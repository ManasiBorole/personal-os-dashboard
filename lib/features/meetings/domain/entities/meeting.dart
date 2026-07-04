import 'package:personal_os_dashboard/core/domain/entities/entity.dart';
import 'package:personal_os_dashboard/features/dashboard/domain/entities/dashboard_summary.dart';

/// Meeting lifecycle status.
enum MeetingStatus {
  scheduled('Scheduled'),
  completed('Completed'),
  cancelled('Cancelled');

  const MeetingStatus(this.label);

  final String label;

  static MeetingStatus fromString(String? value) {
    return MeetingStatus.values.firstWhere(
      (s) => s.name == value?.toLowerCase(),
      orElse: () => MeetingStatus.scheduled,
    );
  }
}

/// Meeting participant.
final class MeetingParticipant extends Entity {
  const MeetingParticipant({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  MeetingParticipant copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
  }) {
    return MeetingParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role];
}

/// Meeting file attachment metadata.
final class MeetingAttachment extends Entity {
  const MeetingAttachment({
    required this.id,
    required this.name,
    required this.storagePath,
    required this.mimeType,
  });

  final String id;
  final String name;
  final String storagePath;
  final String mimeType;

  @override
  List<Object?> get props => [id, name, storagePath, mimeType];
}

/// Full meeting entity.
final class Meeting extends Entity {
  const Meeting({
    required this.id,
    required this.userId,
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
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
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
  final MeetingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  bool get isPast => endTime.isBefore(DateTime.now());

  bool get isUpcoming =>
      status == MeetingStatus.scheduled && !isPast;

  int get participantCount => participants.length;

  Meeting copyWith({
    String? id,
    String? userId,
    String? title,
    String? agenda,
    List<MeetingParticipant>? participants,
    DateTime? startTime,
    int? durationMinutes,
    String? location,
    String? notes,
    String? followUp,
    List<MeetingAttachment>? attachments,
    DateTime? reminderAt,
    MeetingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearLocation = false,
    bool clearReminder = false,
  }) {
    return Meeting(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      agenda: agenda ?? this.agenda,
      participants: participants ?? this.participants,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      location: clearLocation ? null : (location ?? this.location),
      notes: notes ?? this.notes,
      followUp: followUp ?? this.followUp,
      attachments: attachments ?? this.attachments,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  UpcomingMeetingItem toDashboardItem() {
    return UpcomingMeetingItem(
      id: id,
      title: title,
      startTime: startTime,
      durationMinutes: durationMinutes,
      location: location,
      attendeeCount: participantCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        agenda,
        participants,
        startTime,
        durationMinutes,
        location,
        notes,
        followUp,
        attachments,
        reminderAt,
        status,
        createdAt,
        updatedAt,
      ];
}
