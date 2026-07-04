import 'package:personal_os_dashboard/features/meetings/data/datasources/meetings_data_source.dart';
import 'package:personal_os_dashboard/features/meetings/data/models/meeting_model.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';

final class LocalMeetingsDataSource implements MeetingsDataSource {
  final Map<String, MeetingModel> _meetings = {};

  LocalMeetingsDataSource() {
    _seed();
  }

  void _seed() {
    const userId = 'local-user';
    final now = DateTime.now();

    final meetings = [
      MeetingModel(
        id: 'meet-local-1',
        userId: userId,
        title: 'Product sync',
        agenda: '1. Sprint review\n2. Blockers\n3. Next priorities',
        participants: const [
          MeetingParticipant(
            id: 'p-1',
            name: 'Alex Chen',
            email: 'alex@example.com',
            role: 'Host',
          ),
          MeetingParticipant(
            id: 'p-2',
            name: 'Jordan Lee',
            email: 'jordan@example.com',
            role: 'Attendee',
          ),
        ],
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        durationMinutes: 45,
        location: 'Zoom',
        notes: 'Bring Q3 roadmap draft.',
        followUp: 'Send meeting notes to team by EOD.',
        attachments: const [
          MeetingAttachment(
            id: 'att-1',
            name: 'Sprint Board.pdf',
            storagePath: 'meetings/meet-local-1/sprint-board.pdf',
            mimeType: 'application/pdf',
          ),
        ],
        reminderAt: DateTime(now.year, now.month, now.day, 13, 45),
        status: 'scheduled',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      MeetingModel(
        id: 'meet-local-2',
        userId: userId,
        title: 'Design review',
        agenda: 'Review dashboard mockups and component library.',
        participants: const [
          MeetingParticipant(
            id: 'p-3',
            name: 'Sam Rivera',
            email: 'sam@example.com',
            role: 'Host',
          ),
        ],
        startTime: DateTime(now.year, now.month, now.day, 16, 30),
        durationMinutes: 30,
        location: 'Conference Room B',
        notes: '',
        followUp: '',
        attachments: const [],
        reminderAt: DateTime(now.year, now.month, now.day, 16, 15),
        status: 'scheduled',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      MeetingModel(
        id: 'meet-local-3',
        userId: userId,
        title: '1:1 with mentor',
        agenda: 'Career growth and project feedback.',
        participants: const [
          MeetingParticipant(
            id: 'p-4',
            name: 'Dr. Patel',
            email: 'patel@example.com',
            role: 'Mentor',
          ),
        ],
        startTime: now.add(const Duration(days: 1, hours: 10)),
        durationMinutes: 60,
        location: 'Google Meet',
        notes: 'Prepare questions about leadership path.',
        followUp: 'Schedule follow-up in 2 weeks.',
        attachments: const [],
        reminderAt: now.add(const Duration(days: 1, hours: 9)),
        status: 'scheduled',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      MeetingModel(
        id: 'meet-local-4',
        userId: userId,
        title: 'Weekly standup',
        agenda: 'Team status updates.',
        participants: const [
          MeetingParticipant(
            id: 'p-5',
            name: 'Team',
            email: 'team@example.com',
            role: 'Attendee',
          ),
        ],
        startTime: now.subtract(const Duration(days: 7, hours: 2)),
        durationMinutes: 30,
        location: 'Zoom',
        notes: 'Discussed auth module completion.',
        followUp: 'Completed — no action items.',
        attachments: const [],
        reminderAt: null,
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
    ];

    for (final meeting in meetings) {
      _meetings[meeting.id] = meeting;
    }
  }

  @override
  Future<List<MeetingModel>> getMeetings({required String userId}) async {
    return _meetings.values
        .where((m) => m.userId == userId || m.userId == 'local-user')
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<MeetingModel> getMeetingById({required String id}) async {
    final meeting = _meetings[id];
    if (meeting == null) throw StateError('Meeting not found');
    return meeting;
  }

  @override
  Future<MeetingModel> createMeeting({
    required String userId,
    required CreateMeetingParams params,
  }) async {
    final now = DateTime.now();
    final id = 'meet-local-${now.microsecondsSinceEpoch}';
    final meeting = MeetingModel(
      id: id,
      userId: userId,
      title: params.title.trim(),
      agenda: params.agenda.trim(),
      participants: params.participants,
      startTime: params.startTime,
      durationMinutes: params.durationMinutes,
      location: params.location,
      notes: params.notes.trim(),
      followUp: params.followUp.trim(),
      attachments: params.attachments,
      reminderAt: params.reminderAt,
      status: params.status,
      createdAt: now,
      updatedAt: now,
    );
    _meetings[id] = meeting;
    return meeting;
  }

  @override
  Future<MeetingModel> updateMeeting({
    required String userId,
    required UpdateMeetingParams params,
  }) async {
    final existing = await getMeetingById(id: params.id);
    final updated = MeetingModel(
      id: existing.id,
      userId: userId,
      title: params.title.trim(),
      agenda: params.agenda.trim(),
      participants: params.participants,
      startTime: params.startTime,
      durationMinutes: params.durationMinutes,
      location: params.clearLocation ? null : params.location,
      notes: params.notes.trim(),
      followUp: params.followUp.trim(),
      attachments: params.attachments,
      reminderAt: params.clearReminder ? null : params.reminderAt,
      status: params.status,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    _meetings[updated.id] = updated;
    return updated;
  }

  @override
  Future<void> deleteMeeting({required String id}) async {
    _meetings.remove(id);
  }
}
