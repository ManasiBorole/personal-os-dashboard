import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase_storage;

import 'package:personal_os_dashboard/core/error/exceptions.dart' as core;
import 'package:personal_os_dashboard/core/supabase/supabase_exception.dart';
import 'package:personal_os_dashboard/core/supabase/supabase_service.dart';

/// File metadata returned from storage operations.
final class StoredFile {
  const StoredFile({
    required this.bucket,
    required this.path,
    required this.publicUrl,
  });

  final String bucket;
  final String path;
  final String publicUrl;
}

/// Storage service backed by the Supabase Storage client.
final class StorageService {
  StorageService(this._supabaseService);

  final SupabaseService _supabaseService;

  bool get isAvailable =>
      _supabaseService.isConfigured && _supabaseService.isInitialized;

  supabase_storage.SupabaseStorageClient get _storage {
    _ensureAvailable();
    return _supabaseService.storage;
  }

  Future<StoredFile> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
    bool upsert = false,
  }) async {
    try {
      await _storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: supabase_storage.FileOptions(
              contentType: contentType,
              upsert: upsert,
            ),
          );

      return StoredFile(
        bucket: bucket,
        path: path,
        publicUrl: getPublicUrl(bucket: bucket, path: path),
      );
    } on supabase_storage.StorageException catch (error) {
      throw core.StorageException(error.message, cause: error);
    } on Object catch (error) {
      throw core.StorageException('File upload failed', cause: error);
    }
  }

  Future<Uint8List> download({
    required String bucket,
    required String path,
  }) async {
    try {
      return await _storage.from(bucket).download(path);
    } on supabase_storage.StorageException catch (error) {
      throw core.StorageException(error.message, cause: error);
    } on Object catch (error) {
      throw core.StorageException('File download failed', cause: error);
    }
  }

  Future<void> delete({
    required String bucket,
    required String path,
  }) async {
    try {
      await _storage.from(bucket).remove([path]);
    } on supabase_storage.StorageException catch (error) {
      throw core.StorageException(error.message, cause: error);
    } on Object catch (error) {
      throw core.StorageException('File delete failed', cause: error);
    }
  }

  Future<List<supabase_storage.FileObject>> list({
    required String bucket,
    String? path,
  }) async {
    try {
      return await _storage.from(bucket).list(path: path);
    } on supabase_storage.StorageException catch (error) {
      throw core.StorageException(error.message, cause: error);
    } on Object catch (error) {
      throw core.StorageException('File list failed', cause: error);
    }
  }

  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    _ensureAvailable();
    return _storage.from(bucket).getPublicUrl(path);
  }

  void _ensureAvailable() {
    if (!isAvailable) {
      throw const SupabaseNotConfiguredException();
    }
  }
}
