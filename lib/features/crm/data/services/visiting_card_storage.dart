import 'dart:typed_data';

import 'package:personal_os_dashboard/core/constants/api_constants.dart';
import 'package:personal_os_dashboard/core/supabase/domain/repositories/file_storage_repository.dart';

/// Uploads visiting card images to Supabase Storage.
final class VisitingCardStorage {
  const VisitingCardStorage(this._fileStorage);

  final FileStorageRepository _fileStorage;

  Future<({String path, String url})> upload({
    required String userId,
    required String contactId,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final sanitized = fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final path = '$userId/$contactId/$sanitized';
    final stored = await _fileStorage.upload(
      bucket: ApiConstants.visitingCardsBucket,
      path: path,
      bytes: bytes,
      contentType: contentType,
      upsert: true,
    );
    return (path: stored.path, url: stored.publicUrl);
  }
}
