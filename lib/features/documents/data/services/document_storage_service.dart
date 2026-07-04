import 'dart:typed_data';

import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/domain/repositories/file_storage_repository.dart';

/// Uploads and manages files in the documents storage bucket.
final class DocumentStorageService {
  const DocumentStorageService(this._fileStorage);

  final FileStorageRepository _fileStorage;

  Future<({String path, String url})> upload({
    required String userId,
    required String? folderId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final sanitized = fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final folder = folderId ?? 'root';
    final path = '$userId/$folder/$sanitized';
    final stored = await _fileStorage.upload(
      bucket: ApiConstants.documentsBucket,
      path: path,
      bytes: bytes,
      contentType: contentType,
      upsert: true,
    );
    return (path: stored.path, url: stored.publicUrl);
  }

  Future<Uint8List> download({required String storagePath}) {
    return _fileStorage.download(
      bucket: ApiConstants.documentsBucket,
      path: storagePath,
    );
  }

  Future<void> delete({required String storagePath}) {
    return _fileStorage.delete(
      bucket: ApiConstants.documentsBucket,
      path: storagePath,
    );
  }
}
