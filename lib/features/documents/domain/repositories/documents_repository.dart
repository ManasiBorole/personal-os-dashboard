import 'dart:typed_data';

import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_params.dart';

/// Document manager repository contract.
abstract interface class DocumentsRepository {
  Future<List<DocumentFolder>> getFolders({
    required String userId,
    String? parentId,
  });

  Future<DocumentFolder> createFolder({
    required String userId,
    required CreateFolderParams params,
  });

  Future<void> deleteFolder({required String id});

  Future<List<ManagedDocument>> getDocuments({
    required String userId,
    String? folderId,
  });

  Future<ManagedDocument> getDocumentById({required String id});

  Future<ManagedDocument> uploadDocument({
    required String userId,
    required UploadDocumentParams params,
  });

  Future<Uint8List> downloadDocument({required ManagedDocument document});

  Future<void> deleteDocument({required ManagedDocument document});
}
