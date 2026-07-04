import 'dart:typed_data';

import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';

/// Notes repository contract.
abstract interface class NotesRepository {
  Future<List<Note>> getNotes({required String userId});

  Future<Note> getNoteById({required String id});

  Future<Note> createNote({
    required String userId,
    required CreateNoteParams params,
  });

  Future<Note> updateNote({
    required String userId,
    required UpdateNoteParams params,
  });

  Future<void> deleteNote({required String id});

  Future<Note> togglePin({required String id, required bool isPinned});

  Future<Note> toggleArchive({required String id, required bool isArchived});

  Future<NoteAttachment> uploadAttachment({
    required String userId,
    required String noteId,
    required Uint8List bytes,
    required String fileName,
    required bool isImage,
    String? contentType,
  });
}
