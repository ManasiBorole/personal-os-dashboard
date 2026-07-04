import 'dart:typed_data';

import 'package:personal_os_dashboard/core/domain/usecases/usecase.dart';
import 'package:personal_os_dashboard/core/error/exception_mapper.dart';
import 'package:personal_os_dashboard/core/error/result.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';
import 'package:personal_os_dashboard/features/notes/domain/repositories/notes_repository.dart';

typedef UploadNoteAttachmentParams = ({
  String userId,
  String noteId,
  Uint8List bytes,
  String fileName,
  bool isImage,
  String? contentType,
});

final class GetNotesUseCase implements AsyncUseCase<List<Note>, String> {
  const GetNotesUseCase(this._repository);
  final NotesRepository _repository;

  @override
  Future<Result<List<Note>>> call(String userId) async {
    try {
      return Result.success(await _repository.getNotes(userId: userId));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class GetNoteByIdUseCase implements AsyncUseCase<Note, String> {
  const GetNoteByIdUseCase(this._repository);
  final NotesRepository _repository;

  @override
  Future<Result<Note>> call(String id) async {
    try {
      return Result.success(await _repository.getNoteById(id: id));
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateNoteUseCase
    implements AsyncUseCase<Note, CreateNoteRequest> {
  const CreateNoteUseCase(this._repository);
  final NotesRepository _repository;

  @override
  Future<Result<Note>> call(CreateNoteRequest params) async {
    try {
      return Result.success(
        await _repository.createNote(
          userId: params.userId,
          params: params.note,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UpdateNoteUseCase
    implements AsyncUseCase<Note, UpdateNoteRequest> {
  const UpdateNoteUseCase(this._repository);
  final NotesRepository _repository;

  @override
  Future<Result<Note>> call(UpdateNoteRequest params) async {
    try {
      return Result.success(
        await _repository.updateNote(
          userId: params.userId,
          params: params.note,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class DeleteNoteUseCase implements AsyncUseCase<void, String> {
  const DeleteNoteUseCase(this._repository);
  final NotesRepository _repository;

  @override
  Future<Result<void>> call(String id) async {
    try {
      await _repository.deleteNote(id: id);
      return const Result.success(null);
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class ToggleNotePinUseCase
    implements AsyncUseCase<Note, ToggleNotePinRequest> {
  const ToggleNotePinUseCase(this._repository);
  final NotesRepository _repository;

  @override
  Future<Result<Note>> call(ToggleNotePinRequest params) async {
    try {
      return Result.success(
        await _repository.togglePin(
          id: params.id,
          isPinned: params.isPinned,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class ToggleNoteArchiveUseCase
    implements AsyncUseCase<Note, ToggleNoteArchiveRequest> {
  const ToggleNoteArchiveUseCase(this._repository);
  final NotesRepository _repository;

  @override
  Future<Result<Note>> call(ToggleNoteArchiveRequest params) async {
    try {
      return Result.success(
        await _repository.toggleArchive(
          id: params.id,
          isArchived: params.isArchived,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class UploadNoteAttachmentUseCase
    implements AsyncUseCase<NoteAttachment, UploadNoteAttachmentParams> {
  const UploadNoteAttachmentUseCase(this._repository);
  final NotesRepository _repository;

  @override
  Future<Result<NoteAttachment>> call(UploadNoteAttachmentParams params) async {
    try {
      return Result.success(
        await _repository.uploadAttachment(
          userId: params.userId,
          noteId: params.noteId,
          bytes: params.bytes,
          fileName: params.fileName,
          isImage: params.isImage,
          contentType: params.contentType,
        ),
      );
    } on Object catch (e) {
      return Result.failure(ExceptionMapper.mapException(e));
    }
  }
}

final class CreateNoteRequest {
  const CreateNoteRequest({required this.userId, required this.note});
  final String userId;
  final CreateNoteParams note;
}

final class UpdateNoteRequest {
  const UpdateNoteRequest({required this.userId, required this.note});
  final String userId;
  final UpdateNoteParams note;
}

final class ToggleNotePinRequest {
  const ToggleNotePinRequest({required this.id, required this.isPinned});
  final String id;
  final bool isPinned;
}

final class ToggleNoteArchiveRequest {
  const ToggleNoteArchiveRequest({required this.id, required this.isArchived});
  final String id;
  final bool isArchived;
}
