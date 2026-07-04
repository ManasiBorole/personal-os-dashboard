import 'package:personal_os_dashboard/features/documents/domain/entities/document.dart';

final class DocumentFolderModel {
  const DocumentFolderModel({
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

  factory DocumentFolderModel.fromJson(Map<String, dynamic> json) {
    return DocumentFolderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      name: json['name']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  DocumentFolder toEntity() => DocumentFolder(
        id: id,
        userId: userId,
        parentId: parentId,
        name: name,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

final class ManagedDocumentModel {
  const ManagedDocumentModel({
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
  final String fileType;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ManagedDocumentModel.fromJson(Map<String, dynamic> json) {
    return ManagedDocumentModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      folderId: json['folder_id']?.toString(),
      name: json['name']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      storagePath: json['storage_path']?.toString() ?? '',
      publicUrl: json['public_url']?.toString(),
      mimeType: json['mime_type']?.toString() ?? 'application/octet-stream',
      fileType: json['file_type']?.toString() ?? 'other',
      sizeBytes: int.tryParse(json['size_bytes']?.toString() ?? '0') ?? 0,
      createdAt: ManagedDocumentModel._parseDate(json['created_at']) ??
          DateTime.now(),
      updatedAt: ManagedDocumentModel._parseDate(json['updated_at']) ??
          DateTime.now(),
    );
  }

  ManagedDocument toEntity() => ManagedDocument(
        id: id,
        userId: userId,
        folderId: folderId,
        name: name,
        fileName: fileName,
        storagePath: storagePath,
        publicUrl: publicUrl,
        mimeType: mimeType,
        fileType: DocumentFileType.fromString(fileType),
        sizeBytes: sizeBytes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
