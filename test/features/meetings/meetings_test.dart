import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/features/meetings/data/datasources/local_meetings_data_source.dart';
import 'package:personal_os_dashboard/features/meetings/data/repositories/meetings_repository_impl.dart';
import 'package:personal_os_dashboard/features/meetings/data/services/meeting_pdf_exporter.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting_params.dart';
import 'package:personal_os_dashboard/features/meetings/domain/usecases/meeting_usecases.dart';

void main() {
  late MeetingsRepositoryImpl repository;

  setUp(() {
    repository = MeetingsRepositoryImpl(LocalMeetingsDataSource());
  });

  group('Meeting use cases', () {
    test('loads seeded meetings for local user', () async {
      final result = await GetMeetingsUseCase(repository).call('local-user');

      expect(result.isSuccess, isTrue);
      result.when(
        success: (meetings) => expect(meetings.length, greaterThanOrEqualTo(3)),
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('creates, updates, and deletes a meeting', () async {
      const userId = 'test-user';
      final start = DateTime.now().add(const Duration(days: 2, hours: 10));

      final createResult = await CreateMeetingUseCase(repository).call(
        CreateMeetingRequest(
          userId: userId,
          meeting: CreateMeetingParams(
            title: 'Planning session',
            agenda: 'Roadmap review',
            participants: const [
              MeetingParticipant(
                id: 'p-test',
                name: 'Alex',
                email: 'alex@test.com',
                role: 'Host',
              ),
            ],
            startTime: start,
            durationMinutes: 60,
            location: 'Zoom',
            notes: 'Prepare slides',
            followUp: 'Send summary',
            attachments: const [],
            reminderAt: start.subtract(const Duration(minutes: 15)),
            status: MeetingStatus.scheduled.name,
          ),
        ),
      );

      late String meetingId;
      createResult.when(
        success: (meeting) {
          meetingId = meeting.id;
          expect(meeting.title, 'Planning session');
          expect(meeting.participants.length, 1);
        },
        onFailure: (_) => fail('Create failed'),
      );

      final updateResult = await UpdateMeetingUseCase(repository).call(
        UpdateMeetingRequest(
          userId: userId,
          meeting: UpdateMeetingParams(
            id: meetingId,
            title: 'Updated planning',
            agenda: 'Updated agenda',
            participants: const [],
            startTime: start,
            durationMinutes: 45,
            location: null,
            notes: 'Done',
            followUp: '',
            attachments: const [],
            reminderAt: null,
            status: MeetingStatus.completed.name,
            clearLocation: true,
            clearReminder: true,
          ),
        ),
      );

      updateResult.when(
        success: (meeting) {
          expect(meeting.title, 'Updated planning');
          expect(meeting.status, MeetingStatus.completed);
        },
        onFailure: (_) => fail('Update failed'),
      );

      final deleteResult = await DeleteMeetingUseCase(repository).call(meetingId);
      expect(deleteResult.isSuccess, isTrue);
    });

    test('exports meeting as PDF bytes', () async {
      final meetings = await repository.getMeetings(userId: 'local-user');
      final meeting = meetings.first;

      final result =
          await ExportMeetingPdfUseCase(const MeetingPdfExporter()).call(meeting);

      result.when(
        success: (bytes) {
          expect(bytes.isNotEmpty, isTrue);
          expect(String.fromCharCodes(bytes.take(4)), '%PDF');
        },
        onFailure: (_) => fail('Export failed'),
      );
    });
  });
}
