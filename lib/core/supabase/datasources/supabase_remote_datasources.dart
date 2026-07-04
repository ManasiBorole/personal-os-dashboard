import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:personal_os_dashboard/core/supabase/services/database_service.dart';
import 'package:personal_os_dashboard/core/supabase/services/storage_service.dart';

/// Remote data source for database operations.
abstract interface class DatabaseRemoteDataSource {
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns,
    Map<String, dynamic> filters,
    String? orderBy,
    bool ascending,
    int? limit,
  });

  Future<Map<String, dynamic>> selectById({
    required String table,
    required String id,
    String idColumn,
    String columns,
  });

  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
  });

  Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  });

  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params});
}

/// Supabase-backed implementation of [DatabaseRemoteDataSource].
final class SupabaseDatabaseRemoteDataSource implements DatabaseRemoteDataSource {
  SupabaseDatabaseRemoteDataSource(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    Map<String, dynamic> filters = const {},
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) =>
      _databaseService.select(
        table: table,
        columns: columns,
        filters: filters,
        orderBy: orderBy,
        ascending: ascending,
        limit: limit,
      );

  @override
  Future<Map<String, dynamic>> selectById({
    required String table,
    required String id,
    String idColumn = 'id',
    String columns = '*',
  }) =>
      _databaseService.selectById(
        table: table,
        id: id,
        idColumn: idColumn,
        columns: columns,
      );

  @override
  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) =>
      _databaseService.insert(table: table, data: data);

  @override
  Future<Map<String, dynamic>> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
  }) =>
      _databaseService.update(table: table, data: data, filters: filters);

  @override
  Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  }) =>
      _databaseService.delete(table: table, filters: filters);

  @override
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) =>
      _databaseService.rpc(functionName, params: params);
}

/// Remote data source for storage operations.
abstract interface class StorageRemoteDataSource {
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

/// Supabase-backed implementation of [StorageRemoteDataSource].
final class SupabaseStorageRemoteDataSource implements StorageRemoteDataSource {
  SupabaseStorageRemoteDataSource(this._storageService);

  final StorageService _storageService;

  @override
  Future<StoredFile> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
    bool upsert = false,
  }) =>
      _storageService.upload(
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
      _storageService.download(bucket: bucket, path: path);

  @override
  Future<void> delete({
    required String bucket,
    required String path,
  }) =>
      _storageService.delete(bucket: bucket, path: path);

  @override
  Future<List<FileObject>> list({
    required String bucket,
    String? path,
  }) =>
      _storageService.list(bucket: bucket, path: path);

  @override
  String getPublicUrl({
    required String bucket,
    required String path,
  }) =>
      _storageService.getPublicUrl(bucket: bucket, path: path);
}
