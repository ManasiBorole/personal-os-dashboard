import 'dart:typed_data';

import 'package:personal_os_dashboard/features/documents/data/datasources/documents_data_source.dart';
import 'package:personal_os_dashboard/features/documents/data/datasources/local_documents_data_source.dart';
import 'package:personal_os_dashboard/features/documents/data/services/document_storage_service.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_params.dart';
import 'package:personal_os_dashboard/features/documents/domain/repositories/documents_repository.dart';

final class DocumentsRepositoryImpl implements DocumentsRepository {
  DocumentsRepositoryImpl(
    this._dataSource, {
    DocumentStorageService? storageService,
    LocalDocumentsDataSource? localDataSource,
  })  : _storageService = storageService,
        _localDataSource = localDataSource;

  final DocumentsDataSource _dataSource;
  final DocumentStorageService? _storageService;
  final LocalDocumentsDataSource? _localDataSource;

  @override
  Future<List<DocumentFolder>> getFolders({
    required String userId,
    String? parentId,
  }) async {
    final models = await _dataSource.getFolders(
      userId: userId,
      parentId: parentId,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<DocumentFolder> createFolder({
    required String userId,
    required CreateFolderParams params,
  }) async {
    final model = await _dataSource.createFolder(
      userId: userId,
      params: params,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteFolder({required String id}) async {
    await _dataSource.deleteFolder(id: id);
  }

  @override
  Future<List<ManagedDocument>> getDocuments({
    required String userId,
    String? folderId,
  }) async {
    final models = await _dataSource.getDocuments(
      userId: userId,
      folderId: folderId,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ManagedDocument> getDocumentById({required String id}) async {
    final model = await _dataSource.getDocumentById(id: id);
    return model.toEntity();
  }

  @override
  Future<ManagedDocument> uploadDocument({
    required String userId,
    required UploadDocumentParams params,
  }) async {
    final storage = _storageService;
    late final String storagePath;
    late final String? publicUrl;

    if (storage != null) {
      final uploaded = await storage.upload(
        userId: userId,
        folderId: params.folderId,
        bytes: params.bytes,
        fileName: params.fileName,
        contentType: params.mimeType,
      );
      storagePath = uploaded.path;
      publicUrl = uploaded.url;
    } else {
      final folder = params.folderId ?? 'root';
      storagePath = '$userId/$folder/${params.fileName}';
      publicUrl = 'local://$storagePath';
      _localDataSource?.storeBytes(storagePath, params.bytes);
    }

    final model = await _dataSource.insertDocument(
      userId: userId,
      name: params.name,
      folderId: params.folderId,
      fileName: params.fileName,
      storagePath: storagePath,
      publicUrl: publicUrl,
      mimeType: params.mimeType,
      fileType: params.fileType,
      sizeBytes: params.bytes.length,
    );
    return model.toEntity();
  }

  @override
  Future<Uint8List> downloadDocument({
    required ManagedDocument document,
  }) async {
    final storage = _storageService;
    if (storage != null) {
      return storage.download(storagePath: document.storagePath);
    }
    final bytes = _localDataSource?.bytesForPath(document.storagePath);
    if (bytes != null) return Uint8List.fromList(bytes);
    return Uint8List.fromList(List.filled(document.sizeBytes.clamp(1, 1024), 0));
  }

  @override
  Future<void> deleteDocument({required ManagedDocument document}) async {
    final storage = _storageService;
    if (storage != null) {
      await storage.delete(storagePath: document.storagePath);
    }
    await _dataSource.deleteDocumentRecord(id: document.id);
  }
}

DocumentsRepository createDocumentsRepository({
  required bool isSupabaseReady,
  required DocumentsDataSource remoteDataSource,
  DocumentStorageService? storageService,
}) {
  if (isSupabaseReady) {
    return DocumentsRepositoryImpl(
      remoteDataSource,
      storageService: storageService,
    );
  }
  final local = LocalDocumentsDataSource();
  return DocumentsRepositoryImpl(
    local,
    localDataSource: local,
  );
}
