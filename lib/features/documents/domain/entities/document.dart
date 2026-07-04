import 'package:personal_os_dashboard/core/domain/entities/entity.dart';

/// Supported document file types.
enum DocumentFileType {
  pdf('PDF', 'application/pdf'),
  image('Image', 'image/*'),
  excel('Excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
  word('Word', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'),
  other('Other', 'application/octet-stream');

  const DocumentFileType(this.label, this.mimeHint);

  final String label;
  final String mimeHint;

  static DocumentFileType fromString(String? value) {
    return DocumentFileType.values.firstWhere(
      (t) => t.name == value?.toLowerCase(),
      orElse: () => DocumentFileType.other,
    );
  }

  static DocumentFileType fromFileName(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return switch (ext) {
      'pdf' => DocumentFileType.pdf,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' => DocumentFileType.image,
      'xls' || 'xlsx' => DocumentFileType.excel,
      'doc' || 'docx' => DocumentFileType.word,
      _ => DocumentFileType.other,
    };
  }
}

/// Document folder entity.
final class DocumentFolder extends Entity {
  const DocumentFolder({
    required this.id,
    required this.userId,
    required this.parentId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? parentId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, userId, parentId, name, createdAt, updatedAt];
}

/// Managed document file entity.
final class ManagedDocument extends Entity {
  const ManagedDocument({
    required this.id,
    required this.userId,
    required this.folderId,
    required this.name,
    required this.fileName,
    required this.storagePath,
    required this.publicUrl,
    required this.mimeType,
    required this.fileType,
    required this.sizeBytes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? folderId;
  final String name;
  final String fileName;
  final String storagePath;
  final String? publicUrl;
  final String mimeType;
  final DocumentFileType fileType;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get canPreviewImage => fileType == DocumentFileType.image;

  bool get canPreviewExcel => fileType == DocumentFileType.excel;

  @override
  List<Object?> get props => [
        id,
        userId,
        folderId,
        name,
        fileName,
        storagePath,
        publicUrl,
        mimeType,
        fileType,
        sizeBytes,
        createdAt,
        updatedAt,
      ];
}
