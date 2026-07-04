import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:personal_os_dashboard/core/supabase/services/storage_service.dart';

/// Contract for file storage operations.
abstract interface class FileStorageRepository {
  Future<StoredFile> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
    bool upsert,
  });

  Future<Uint8List> download({
    required String bucket,
    required String path,
  });

  Future<void> delete({
    required String bucket,
    required String path,
  });

  Future<List<FileObject>> list({
    required String bucket,
    String? path,
  });

  String getPublicUrl({
    required String bucket,
    required String path,
  });
}
