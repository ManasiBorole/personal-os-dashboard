import 'dart:typed_data';

import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';

/// Parameters for creating a folder.
final class CreateFolderParams {
  const CreateFolderParams({
    required this.name,
    required this.parentId,
  });

  final String name;
  final String? parentId;
}

/// Parameters for uploading a document.
final class UploadDocumentParams {
  const UploadDocumentParams({
    required this.name,
    required this.folderId,
    required this.fileName,
    required this.bytes,
    required this.mimeType,
    required this.fileType,
  });

  final String name;
  final String? folderId;
  final String fileName;
  final Uint8List bytes;
  final String mimeType;
  final String fileType;
}

enum DocumentFilterType {
  all('All'),
  pdf('PDF'),
  image('Images'),
  excel('Excel'),
  word('Word');

  const DocumentFilterType(this.label);

  final String label;

  DocumentFileType? get fileType => switch (this) {
        DocumentFilterType.all => null,
        DocumentFilterType.pdf => DocumentFileType.pdf,
        DocumentFilterType.image => DocumentFileType.image,
        DocumentFilterType.excel => DocumentFileType.excel,
        DocumentFilterType.word => DocumentFileType.word,
      };
}
