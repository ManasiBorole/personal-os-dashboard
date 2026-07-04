import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:personal_os_dashboard/core/supabase/datasources/supabase_remote_datasources.dart';
import 'package:personal_os_dashboard/core/supabase/domain/repositories/file_storage_repository.dart';
import 'package:personal_os_dashboard/core/supabase/services/storage_service.dart';

/// Repository implementation for Supabase file storage.
final class FileStorageRepositoryImpl implements FileStorageRepository {
  FileStorageRepositoryImpl(this._dataSource);

  final StorageRemoteDataSource _dataSource;

  @override
  Future<StoredFile> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
    bool upsert = false,
  }) =>
      _dataSource.upload(
        bucket: bucket,
        path: path,
        bytes: bytes,
        contentType: contentType,
        upsert: upsert,
      );

  @override
  Future<Uint8List> download({
    required String bucket,
    required String path,
  }) =>
      _dataSource.download(bucket: bucket, path: path);

  @override
  Future<void> delete({
    required String bucket,
    required String path,
  }) =>
      _dataSource.delete(bucket: bucket, path: path);

  @override
  Future<List<FileObject>> list({
    required String bucket,
    String? path,
  }) =>
      _dataSource.list(bucket: bucket, path: path);

  @override
  String getPublicUrl({
    required String bucket,
    required String path,
  }) =>
      _dataSource.getPublicUrl(bucket: bucket, path: path);
}
