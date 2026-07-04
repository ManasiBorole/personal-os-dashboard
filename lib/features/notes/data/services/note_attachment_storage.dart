import 'dart:typed_data';

import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/domain/repositories/file_storage_repository.dart';

/// Uploads note images and documents to Supabase Storage.
final class NoteAttachmentStorage {
  const NoteAttachmentStorage(this._fileStorage);

  final FileStorageRepository _fileStorage;

  Future<({String path, String url})> upload({
    required String userId,
    required String noteId,
    required Uint8List bytes,
    required String fileName,
    required bool isImage,
    String? contentType,
  }) async {
    final sanitized = fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final folder = isImage ? 'images' : 'documents';
    final path = '$userId/$noteId/$folder/$sanitized';
    final stored = await _fileStorage.upload(
      bucket: ApiConstants.noteAttachmentsBucket,
      path: path,
      bytes: bytes,
      contentType: contentType,
      upsert: true,
    );
    return (path: stored.path, url: stored.publicUrl);
  }
}
