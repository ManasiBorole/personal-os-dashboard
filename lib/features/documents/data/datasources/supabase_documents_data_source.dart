import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/features/documents/data/datasources/documents_data_source.dart';
import 'package:personal_os_dashboard/features/documents/data/models/document_model.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_params.dart';

final class SupabaseDocumentsDataSource implements DocumentsDataSource {
  SupabaseDocumentsDataSource(this._database);

  final DatabaseRemoteDataSource _database;

  static const _foldersTable = 'document_folders';

  @override
  Future<List<DocumentFolderModel>> getFolders({
    required String userId,
    String? parentId,
  }) async {
    final filters = <String, dynamic>{'user_id': userId};
    if (parentId == null) {
      // PostgREST is.null filter
      final rows = await _database.select(
        table: _foldersTable,
        filters: filters,
        orderBy: 'name',
        ascending: true,
      );
      return rows
          .map(DocumentFolderModel.fromJson)
          .where((f) => f.parentId == null)
          .toList();
    }
    filters['parent_id'] = parentId;
    final rows = await _database.select(
      table: _foldersTable,
      filters: filters,
      orderBy: 'name',
      ascending: true,
    );
    return rows.map(DocumentFolderModel.fromJson).toList();
  }

  @override
  Future<DocumentFolderModel> createFolder({
    required String userId,
    required CreateFolderParams params,
  }) async {
    final row = await _database.insert(
      table: _foldersTable,
      data: {
        'user_id': userId,
        'parent_id': params.parentId,
        'name': params.name.trim(),
      },
    );
    return DocumentFolderModel.fromJson(row);
  }

  @override
  Future<void> deleteFolder({required String id}) async {
    await _database.delete(
      table: _foldersTable,
      filters: {'id': id},
    );
  }

  @override
  Future<List<ManagedDocumentModel>> getDocuments({
    required String userId,
    String? folderId,
  }) async {
    final filters = <String, dynamic>{'user_id': userId};
    if (folderId != null) {
      filters['folder_id'] = folderId;
    }
    final rows = await _database.select(
      table: ApiConstants.documentsTable,
      filters: filters,
      orderBy: 'updated_at',
      ascending: false,
    );
    final docs = rows.map(ManagedDocumentModel.fromJson).toList();
    if (folderId == null) {
      return docs.where((d) => d.folderId == null).toList();
    }
    return docs;
  }

  @override
  Future<ManagedDocumentModel> getDocumentById({required String id}) async {
    final row = await _database.selectById(
      table: ApiConstants.documentsTable,
      id: id,
    );
    return ManagedDocumentModel.fromJson(row);
  }

  @override
  Future<ManagedDocumentModel> insertDocument({
    required String userId,
    required String name,
    required String? folderId,
    required String fileName,
    required String storagePath,
    required String? publicUrl,
    required String mimeType,
    required String fileType,
    required int sizeBytes,
  }) async {
    final row = await _database.insert(
      table: ApiConstants.documentsTable,
      data: {
        'user_id': userId,
        'folder_id': folderId,
        'name': name.trim(),
        'file_name': fileName,
        'storage_path': storagePath,
        'public_url': publicUrl,
        'mime_type': mimeType,
        'file_type': fileType,
        'size_bytes': sizeBytes,
      },
    );
    return ManagedDocumentModel.fromJson(row);
  }

  @override
  Future<void> deleteDocumentRecord({required String id}) async {
    await _database.delete(
      table: ApiConstants.documentsTable,
      filters: {'id': id},
    );
  }
}
