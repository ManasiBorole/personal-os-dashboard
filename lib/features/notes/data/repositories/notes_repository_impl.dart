import 'dart:typed_data';

import 'package:personal_os_dashboard/features/notes/data/datasources/local_notes_data_source.dart';
import 'package:personal_os_dashboard/features/notes/data/datasources/notes_data_source.dart';
import 'package:personal_os_dashboard/features/notes/data/services/note_attachment_storage.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';
import 'package:personal_os_dashboard/features/notes/domain/repositories/notes_repository.dart';

final class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(
    this._dataSource, {
    NoteAttachmentStorage? attachmentStorage,
  }) : _attachmentStorage = attachmentStorage;

  final NotesDataSource _dataSource;
  final NoteAttachmentStorage? _attachmentStorage;

  @override
  Future<List<Note>> getNotes({required String userId}) async {
    final models = await _dataSource.getNotes(userId: userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Note> getNoteById({required String id}) async {
    final model = await _dataSource.getNoteById(id: id);
    return model.toEntity();
  }

  @override
  Future<Note> createNote({
    required String userId,
    required CreateNoteParams params,
  }) async {
    final model = await _dataSource.createNote(userId: userId, params: params);
    return model.toEntity();
  }

  @override
  Future<Note> updateNote({
    required String userId,
    required UpdateNoteParams params,
  }) async {
    final model = await _dataSource.updateNote(userId: userId, params: params);
    return model.toEntity();
  }

  @override
  Future<void> deleteNote({required String id}) async {
    await _dataSource.deleteNote(id: id);
  }

  @override
  Future<Note> togglePin({required String id, required bool isPinned}) async {
    final model = await _dataSource.togglePin(id: id, isPinned: isPinned);
    return model.toEntity();
  }

  @override
  Future<Note> toggleArchive({
    required String id,
    required bool isArchived,
  }) async {
    final model =
        await _dataSource.toggleArchive(id: id, isArchived: isArchived);
    return model.toEntity();
  }

  @override
  Future<NoteAttachment> uploadAttachment({
    required String userId,
    required String noteId,
    required Uint8List bytes,
    required String fileName,
    required bool isImage,
    String? contentType,
  }) async {
    final storage = _attachmentStorage;
    if (storage != null) {
      final uploaded = await storage.upload(
        userId: userId,
        noteId: noteId,
        bytes: bytes,
        fileName: fileName,
        isImage: isImage,
        contentType: contentType,
      );
      return NoteAttachment(
        id: 'att-${DateTime.now().microsecondsSinceEpoch}',
        name: fileName,
        storagePath: uploaded.path,
        publicUrl: uploaded.url,
        mimeType: contentType ?? (isImage ? 'image/jpeg' : 'application/octet-stream'),
        isImage: isImage,
      );
    }
    final path = '$userId/$noteId/${isImage ? 'images' : 'documents'}/$fileName';
    return NoteAttachment(
      id: 'att-${DateTime.now().microsecondsSinceEpoch}',
      name: fileName,
      storagePath: path,
      publicUrl: 'local://$path',
      mimeType: contentType ?? (isImage ? 'image/jpeg' : 'application/octet-stream'),
      isImage: isImage,
    );
  }
}

final class UnconfiguredNotesRepository implements NotesRepository {
  UnconfiguredNotesRepository()
      : _delegate = NotesRepositoryImpl(LocalNotesDataSource());

  final NotesRepositoryImpl _delegate;

  @override
  Future<List<Note>> getNotes({required String userId}) =>
      _delegate.getNotes(userId: userId);

  @override
  Future<Note> getNoteById({required String id}) =>
      _delegate.getNoteById(id: id);

  @override
  Future<Note> createNote({
    required String userId,
    required CreateNoteParams params,
  }) =>
      _delegate.createNote(userId: userId, params: params);

  @override
  Future<Note> updateNote({
    required String userId,
    required UpdateNoteParams params,
  }) =>
      _delegate.updateNote(userId: userId, params: params);

  @override
  Future<void> deleteNote({required String id}) =>
      _delegate.deleteNote(id: id);

  @override
  Future<Note> togglePin({required String id, required bool isPinned}) =>
      _delegate.togglePin(id: id, isPinned: isPinned);

  @override
  Future<Note> toggleArchive({
    required String id,
    required bool isArchived,
  }) =>
      _delegate.toggleArchive(id: id, isArchived: isArchived);

  @override
  Future<NoteAttachment> uploadAttachment({
    required String userId,
    required String noteId,
    required Uint8List bytes,
    required String fileName,
    required bool isImage,
    String? contentType,
  }) =>
      _delegate.uploadAttachment(
        userId: userId,
        noteId: noteId,
        bytes: bytes,
        fileName: fileName,
        isImage: isImage,
        contentType: contentType,
      );
}

NotesRepository createNotesRepository({
  required bool isSupabaseReady,
  required NotesDataSource remoteDataSource,
  NoteAttachmentStorage? attachmentStorage,
}) {
  if (isSupabaseReady) {
    return NotesRepositoryImpl(
      remoteDataSource,
      attachmentStorage: attachmentStorage,
    );
  }
  return UnconfiguredNotesRepository();
}
