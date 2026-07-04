import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:personal_os_dashboard/features/documents/data/datasources/local_documents_data_source.dart';
import 'package:personal_os_dashboard/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';
import 'package:personal_os_dashboard/features/documents/domain/entities/document_params.dart';
import 'package:personal_os_dashboard/features/documents/domain/usecases/document_usecases.dart';

void main() {
  late DocumentsRepositoryImpl repository;
  late LocalDocumentsDataSource localDataSource;

  setUp(() {
    localDataSource = LocalDocumentsDataSource();
    repository = DocumentsRepositoryImpl(
      localDataSource,
      localDataSource: localDataSource,
    );
  });

  group('Documents use cases', () {
    test('loads seeded folders and documents for local user', () async {
      final folders = await GetFoldersUseCase(repository).call(
        const GetFoldersRequest(userId: 'local-user'),
      );
      final documents = await GetDocumentsUseCase(repository).call(
        const GetDocumentsRequest(userId: 'local-user'),
      );

      folders.when(
        success: (value) => expect(value.length, greaterThanOrEqualTo(2)),
        onFailure: (_) => fail('Expected folders'),
      );
      documents.when(
        success: (value) => expect(value.length, greaterThanOrEqualTo(1)),
        onFailure: (_) => fail('Expected documents'),
      );
    });

    test('creates folder and uploads document', () async {
      const userId = 'test-user';

      final folderResult = await CreateFolderUseCase(repository).call(
        CreateFolderRequest(
          userId: userId,
          folder: const CreateFolderParams(
            name: 'Uploads',
            parentId: null,
          ),
        ),
      );

      late String folderId;
      folderResult.when(
        success: (folder) {
          folderId = folder.id;
          expect(folder.name, 'Uploads');
        },
        onFailure: (_) => fail('Create folder failed'),
      );

      final uploadResult = await UploadDocumentUseCase(repository).call(
        UploadDocumentRequest(
          userId: userId,
          document: UploadDocumentParams(
            name: 'Test PDF',
            folderId: folderId,
            fileName: 'test.pdf',
            bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
            mimeType: 'application/pdf',
            fileType: DocumentFileType.pdf.name,
          ),
        ),
      );

      late ManagedDocument uploaded;
      uploadResult.when(
        success: (doc) {
          uploaded = doc;
          expect(doc.fileType, DocumentFileType.pdf);
        },
        onFailure: (_) => fail('Upload failed'),
      );

      final downloadResult =
          await DownloadDocumentUseCase(repository).call(uploaded);
      downloadResult.when(
        success: (bytes) => expect(bytes.isNotEmpty, isTrue),
        onFailure: (_) => fail('Download failed'),
      );

      final deleteResult =
          await DeleteDocumentUseCase(repository).call(uploaded);
      expect(deleteResult.isSuccess, isTrue);
    });

    test('lists documents in nested folder', () async {
      final result = await GetDocumentsUseCase(repository).call(
        const GetDocumentsRequest(
          userId: 'local-user',
          folderId: 'folder-local-2',
        ),
      );

      result.when(
        success: (docs) => expect(docs.any((d) => d.fileType == DocumentFileType.excel), isTrue),
        onFailure: (_) => fail('Expected documents in folder'),
      );
    });
  });
}
