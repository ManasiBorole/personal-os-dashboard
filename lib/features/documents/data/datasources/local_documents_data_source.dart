import 'package:personal_os_dashboard/features/documents/data/datasources/documents_data_source.dart';
import 'package:personal_os_dashboard/features/documents/data/models/document_model.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_params.dart';

final class LocalDocumentsDataSource implements DocumentsDataSource {
  final Map<String, DocumentFolderModel> _folders = {};
  final Map<String, ManagedDocumentModel> _documents = {};
  final Map<String, List<int>> _fileBytes = {};

  LocalDocumentsDataSource() {
    _seed();
  }

  void _seed() {
    const userId = 'local-user';
    final now = DateTime.now();

    final folders = [
      DocumentFolderModel(
        id: 'folder-local-1',
        userId: userId,
        parentId: null,
        name: 'Work',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      DocumentFolderModel(
        id: 'folder-local-2',
        userId: userId,
        parentId: 'folder-local-1',
        name: 'Reports',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      DocumentFolderModel(
        id: 'folder-local-3',
        userId: userId,
        parentId: null,
        name: 'Personal',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    for (final folder in folders) {
      _folders[folder.id] = folder;
    }

    final documents = [
      ManagedDocumentModel(
        id: 'doc-local-1',
        userId: userId,
        folderId: null,
        name: 'Product Roadmap',
        fileName: 'roadmap.pdf',
        storagePath: '$userId/root/roadmap.pdf',
        publicUrl: 'local://roadmap.pdf',
        mimeType: 'application/pdf',
        fileType: DocumentFileType.pdf.name,
        sizeBytes: 245760,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ManagedDocumentModel(
        id: 'doc-local-2',
        userId: userId,
        folderId: 'folder-local-1',
        name: 'Team Photo',
        fileName: 'team.jpg',
        storagePath: '$userId/folder-local-1/team.jpg',
        publicUrl: 'local://team.jpg',
        mimeType: 'image/jpeg',
        fileType: DocumentFileType.image.name,
        sizeBytes: 512000,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      ManagedDocumentModel(
        id: 'doc-local-3',
        userId: userId,
        folderId: 'folder-local-2',
        name: 'Q2 Budget',
        fileName: 'budget.xlsx',
        storagePath: '$userId/folder-local-2/budget.xlsx',
        publicUrl: 'local://budget.xlsx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        fileType: DocumentFileType.excel.name,
        sizeBytes: 89000,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      ManagedDocumentModel(
        id: 'doc-local-4',
        userId: userId,
        folderId: 'folder-local-3',
        name: 'Meeting Notes',
        fileName: 'notes.docx',
        storagePath: '$userId/folder-local-3/notes.docx',
        publicUrl: 'local://notes.docx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        fileType: DocumentFileType.word.name,
        sizeBytes: 42000,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];

    for (final doc in documents) {
      _documents[doc.id] = doc;
      _fileBytes[doc.storagePath] = List<int>.filled(64, 0);
    }
  }

  @override
  Future<List<DocumentFolderModel>> getFolders({
    required String userId,
    String? parentId,
  }) async {
    return _folders.values
        .where(
          (f) =>
              (f.userId == userId || f.userId == 'local-user') &&
              f.parentId == parentId,
        )
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<DocumentFolderModel> createFolder({
    required String userId,
    required CreateFolderParams params,
  }) async {
    final now = DateTime.now();
    final id = 'folder-local-${now.microsecondsSinceEpoch}';
    final folder = DocumentFolderModel(
      id: id,
      userId: userId,
      parentId: params.parentId,
      name: params.name.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _folders[id] = folder;
    return folder;
  }

  @override
  Future<void> deleteFolder({required String id}) async {
    _folders.remove(id);
    for (final entry in _documents.entries.toList()) {
      if (entry.value.folderId == id) {
        _documents.remove(entry.key);
      }
    }
    for (final child in _folders.values.where((f) => f.parentId == id)) {
      await deleteFolder(id: child.id);
    }
  }

  @override
  Future<List<ManagedDocumentModel>> getDocuments({
    required String userId,
    String? folderId,
  }) async {
    return _documents.values
        .where(
          (d) =>
              (d.userId == userId || d.userId == 'local-user') &&
              d.folderId == folderId,
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<ManagedDocumentModel> getDocumentById({required String id}) async {
    final doc = _documents[id];
    if (doc == null) throw StateError('Document not found');
    return doc;
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
    final now = DateTime.now();
    final id = 'doc-local-${now.microsecondsSinceEpoch}';
    final doc = ManagedDocumentModel(
      id: id,
      userId: userId,
      folderId: folderId,
      name: name.trim(),
      fileName: fileName,
      storagePath: storagePath,
      publicUrl: publicUrl,
      mimeType: mimeType,
      fileType: fileType,
      sizeBytes: sizeBytes,
      createdAt: now,
      updatedAt: now,
    );
    _documents[id] = doc;
    return doc;
  }

  @override
  Future<void> deleteDocumentRecord({required String id}) async {
    final doc = _documents.remove(id);
    if (doc != null) {
      _fileBytes.remove(doc.storagePath);
    }
  }

  List<int>? bytesForPath(String path) => _fileBytes[path];

  void storeBytes(String path, List<int> bytes) {
    _fileBytes[path] = bytes;
  }
}
