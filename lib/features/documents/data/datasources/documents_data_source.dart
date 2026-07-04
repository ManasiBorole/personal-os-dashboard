import 'package:personal_os_dashboard/features/documents/data/models/document_model.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_params.dart';

/// Data source contract for document manager.
abstract interface class DocumentsDataSource {
  Future<List<DocumentFolderModel>> getFolders({
    required String userId,
    String? parentId,
  });

  Future<DocumentFolderModel> createFolder({
    required String userId,
    required CreateFolderParams params,
  });

  Future<void> deleteFolder({required String id});

  Future<List<ManagedDocumentModel>> getDocuments({
    required String userId,
    String? folderId,
  });

  Future<ManagedDocumentModel> getDocumentById({required String id});

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
  });

  Future<void> deleteDocumentRecord({required String id});
}
