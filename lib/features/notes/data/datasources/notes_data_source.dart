import 'package:personal_os_dashboard/features/notes/data/models/note_model.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';

/// Data source contract for notes.
abstract interface class NotesDataSource {
  Future<List<NoteModel>> getNotes({required String userId});

  Future<NoteModel> getNoteById({required String id});

  Future<NoteModel> createNote({
    required String userId,
    required CreateNoteParams params,
  });

  Future<NoteModel> updateNote({
    required String userId,
    required UpdateNoteParams params,
  });

  Future<void> deleteNote({required String id});

  Future<NoteModel> togglePin({required String id, required bool isPinned});

  Future<NoteModel> toggleArchive({
    required String id,
    required bool isArchived,
  });
}
