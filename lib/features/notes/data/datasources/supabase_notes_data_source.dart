import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/features/notes/data/datasources/notes_data_source.dart';
import 'package:personal_os_dashboard/features/notes/data/models/note_model.dart';
import 'package:personal_os_dashboard/features/notes/domain/entities/note_params.dart';

final class SupabaseNotesDataSource implements NotesDataSource {
  SupabaseNotesDataSource(this._database);

  final DatabaseRemoteDataSource _database;

  @override
  Future<List<NoteModel>> getNotes({required String userId}) async {
    final rows = await _database.select(
      table: ApiConstants.notesTable,
      filters: {'user_id': userId},
      orderBy: 'updated_at',
      ascending: false,
    );
    return rows.map(NoteModel.fromJson).toList();
  }

  @override
  Future<NoteModel> getNoteById({required String id}) async {
    final row = await _database.selectById(
      table: ApiConstants.notesTable,
      id: id,
    );
    return NoteModel.fromJson(row);
  }

  @override
  Future<NoteModel> createNote({
    required String userId,
    required CreateNoteParams params,
  }) async {
    final row = await _database.insert(
      table: ApiConstants.notesTable,
      data: {
        'user_id': userId,
        'title': params.title.trim(),
        'content': params.content.trim(),
        'note_type': params.type,
        'checklist': params.checklist.map(NoteModel.checklistToJson).toList(),
        'category': params.category,
        'tags': params.tags,
        'images': params.images.map(NoteModel.attachmentToJson).toList(),
        'documents': params.documents.map(NoteModel.attachmentToJson).toList(),
        'is_pinned': params.isPinned,
        'is_archived': false,
      },
    );
    return NoteModel.fromJson(row);
  }

  @override
  Future<NoteModel> updateNote({
    required String userId,
    required UpdateNoteParams params,
  }) async {
    final row = await _database.update(
      table: ApiConstants.notesTable,
      data: {
        'title': params.title.trim(),
        'content': params.content.trim(),
        'note_type': params.type,
        'checklist': params.checklist.map(NoteModel.checklistToJson).toList(),
        'category': params.category,
        'tags': params.tags,
        'images': params.images.map(NoteModel.attachmentToJson).toList(),
        'documents': params.documents.map(NoteModel.attachmentToJson).toList(),
        'is_pinned': params.isPinned,
        'is_archived': params.isArchived,
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': params.id, 'user_id': userId},
    );
    return NoteModel.fromJson(row);
  }

  @override
  Future<void> deleteNote({required String id}) async {
    await _database.delete(
      table: ApiConstants.notesTable,
      filters: {'id': id},
    );
  }

  @override
  Future<NoteModel> togglePin({
    required String id,
    required bool isPinned,
  }) async {
    final row = await _database.update(
      table: ApiConstants.notesTable,
      data: {
        'is_pinned': isPinned,
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': id},
    );
    return NoteModel.fromJson(row);
  }

  @override
  Future<NoteModel> toggleArchive({
    required String id,
    required bool isArchived,
  }) async {
    final existing = await getNoteById(id: id);
    final row = await _database.update(
      table: ApiConstants.notesTable,
      data: {
        'is_archived': isArchived,
        'is_pinned': isArchived ? false : existing.isPinned,
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: {'id': id},
    );
    return NoteModel.fromJson(row);
  }
}
