import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/features/notes/data/datasources/local_notes_data_source.dart';
import 'package:personal_os_dashboard/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';
import 'package:personal_os_dashboard/features/notes/domain/usecases/note_usecases.dart';

void main() {
  late NotesRepositoryImpl repository;

  setUp(() {
    repository = NotesRepositoryImpl(LocalNotesDataSource());
  });

  group('Notes use cases', () {
    test('loads seeded notes for local user', () async {
      final result = await GetNotesUseCase(repository).call('local-user');

      expect(result.isSuccess, isTrue);
      result.when(
        success: (notes) => expect(notes.length, greaterThanOrEqualTo(3)),
        onFailure: (_) => fail('Expected success'),
      );
    });

    test('creates, updates, pins, archives, and deletes a note', () async {
      const userId = 'test-user';

      final createResult = await CreateNoteUseCase(repository).call(
        CreateNoteRequest(
          userId: userId,
          note: CreateNoteParams(
            title: 'Test note',
            content: 'Hello world',
            type: NoteType.text.name,
            checklist: const [],
            category: NoteCategory.ideas.name,
            tags: const ['test'],
            images: const [],
            documents: const [],
          ),
        ),
      );

      late String noteId;
      createResult.when(
        success: (note) {
          noteId = note.id;
          expect(note.title, 'Test note');
        },
        onFailure: (_) => fail('Create failed'),
      );

      final pinResult = await ToggleNotePinUseCase(repository).call(
        ToggleNotePinRequest(id: noteId, isPinned: true),
      );
      pinResult.when(
        success: (note) => expect(note.isPinned, isTrue),
        onFailure: (_) => fail('Pin failed'),
      );

      final updateResult = await UpdateNoteUseCase(repository).call(
        UpdateNoteRequest(
          userId: userId,
          note: UpdateNoteParams(
            id: noteId,
            title: 'Updated note',
            content: 'Updated content',
            type: NoteType.checklist.name,
            checklist: const [
              NoteChecklistItem(id: 'c-1', text: 'Item 1', isChecked: false),
            ],
            category: NoteCategory.work.name,
            tags: const ['updated'],
            images: const [],
            documents: const [],
            isPinned: true,
            isArchived: false,
          ),
        ),
      );

      updateResult.when(
        success: (note) {
          expect(note.title, 'Updated note');
          expect(note.type, NoteType.checklist);
        },
        onFailure: (_) => fail('Update failed'),
      );

      final archiveResult = await ToggleNoteArchiveUseCase(repository).call(
        ToggleNoteArchiveRequest(id: noteId, isArchived: true),
      );
      archiveResult.when(
        success: (note) {
          expect(note.isArchived, isTrue);
          expect(note.isPinned, isFalse);
        },
        onFailure: (_) => fail('Archive failed'),
      );

      final deleteResult = await DeleteNoteUseCase(repository).call(noteId);
      expect(deleteResult.isSuccess, isTrue);
    });

    test('filters archived notes in seeded data', () async {
      final result = await GetNotesUseCase(repository).call('local-user');

      result.when(
        success: (notes) {
          final archived = notes.where((n) => n.isArchived).length;
          final active = notes.where((n) => !n.isArchived).length;
          expect(archived, greaterThanOrEqualTo(1));
          expect(active, greaterThanOrEqualTo(2));
        },
        onFailure: (_) => fail('Expected success'),
      );
    });
  });
}
