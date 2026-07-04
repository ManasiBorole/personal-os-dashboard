import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:personal_os_dashboard/core/error/exceptions.dart';
import 'package:personal_os_dashboard/core/supabase/supabase_exception.dart';
import 'package:personal_os_dashboard/core/supabase/supabase_service.dart';

/// Database service backed by the Supabase PostgREST client.
final class DatabaseService {
  DatabaseService(this._supabaseService);

  final SupabaseService _supabaseService;

  bool get isAvailable =>
      _supabaseService.isConfigured && _supabaseService.isInitialized;

  SupabaseQueryBuilder from(String table) {
    _ensureAvailable();
    return _supabaseService.from(table);
  }

  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    Map<String, dynamic> filters = const {},
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic query = from(table).select(columns);

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query as List;
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (error) {
      throw ServerException(error.message, statusCode: error.code != null ? int.tryParse(error.code!) : null);
    } on Object catch (error) {
      throw ServerException('Database select failed', cause: error);
    }
  }

  Future<Map<String, dynamic>> selectById({
    required String table,
    required String id,
    String idColumn = 'id',
    String columns = '*',
  }) async {
    try {
      final response = await from(table)
          .select(columns)
          .eq(idColumn, id)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundException('Record not found');
      }

      return Map<String, dynamic>.from(response as Map);
    } on AppException {
      rethrow;
    } on PostgrestException catch (error) {
      throw ServerException(error.message, statusCode: error.code != null ? int.tryParse(error.code!) : null);
    } on Object catch (error) {
      throw ServerException('Database selectById failed', cause: error);
    }
  }

  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await from(table).insert(data).select().single();
      return Map<String, dynamic>.from(response as Map);
    } on PostgrestException catch (error) {
      throw ServerException(error.message, statusCode: error.code != null ? int.tryParse(error.code!) : null);
    } on Object catch (error) {
      throw ServerException('Database insert failed', cause: error);
    }
  }

  Future<Map<String, dynamic>> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
  }) async {
    try {
      var query = from(table).update(data);

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      final response = await query.select().single();
      return Map<String, dynamic>.from(response as Map);
    } on PostgrestException catch (error) {
      throw ServerException(error.message, statusCode: error.code != null ? int.tryParse(error.code!) : null);
    } on Object catch (error) {
      throw ServerException('Database update failed', cause: error);
    }
  }

  Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  }) async {
    try {
      var query = from(table).delete();

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      await query;
    } on PostgrestException catch (error) {
      throw ServerException(error.message, statusCode: error.code != null ? int.tryParse(error.code!) : null);
    } on Object catch (error) {
      throw ServerException('Database delete failed', cause: error);
    }
  }

  Future<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      return await _supabaseService.rpc(functionName, params: params);
    } on PostgrestException catch (error) {
      throw ServerException(error.message, statusCode: error.code != null ? int.tryParse(error.code!) : null);
    } on Object catch (error) {
      throw ServerException('Database RPC failed', cause: error);
    }
  }

  void _ensureAvailable() {
    if (!isAvailable) {
      throw const SupabaseNotConfiguredException();
    }
  }
}
