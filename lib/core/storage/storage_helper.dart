import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:personal_os_dashboard/core/constants/storage_constants.dart';
import 'package:personal_os_dashboard/core/error/exceptions.dart';
import 'package:personal_os_dashboard/core/logging/app_logger.dart';

/// Unified local storage helper for Hive cache and secure storage.
final class StorageHelper {
  StorageHelper(this._logger);

  final AppLogger _logger;

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Box<dynamic>? _cacheBox;
  Box<dynamic>? _settingsBox;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initializes Hive and opens required boxes.
  ///
  /// Pass [path] in tests to avoid platform channel dependencies.
  Future<void> init({String? path}) async {
    if (_isInitialized) return;

    try {
      if (path != null) {
        Hive.init(path);
      } else {
        await Hive.initFlutter();
      }
      _cacheBox = await Hive.openBox<dynamic>(StorageConstants.cacheBox);
      _settingsBox = await Hive.openBox<dynamic>(StorageConstants.settingsBox);
      _isInitialized = true;
      _logger.info('StorageHelper initialized');
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize StorageHelper',
        error: error,
        stackTrace: stackTrace,
      );
      throw StorageException('Failed to initialize local storage', cause: error);
    }
  }

  // Hive cache operations

  Future<void> writeCache(String key, dynamic value) async {
    _ensureInitialized();
    try {
      await _cacheBox!.put(key, value);
    } on Object catch (error) {
      throw StorageException('Failed to write cache key: $key', cause: error);
    }
  }

  T? readCache<T>(String key, {T? defaultValue}) {
    _ensureInitialized();
    try {
      final value = _cacheBox!.get(key, defaultValue: defaultValue);
      return value as T?;
    } on Object catch (error) {
      throw StorageException('Failed to read cache key: $key', cause: error);
    }
  }

  Future<void> deleteCache(String key) async {
    _ensureInitialized();
    try {
      await _cacheBox!.delete(key);
    } on Object catch (error) {
      throw StorageException('Failed to delete cache key: $key', cause: error);
    }
  }

  Future<void> clearCache() async {
    _ensureInitialized();
    try {
      await _cacheBox!.clear();
    } on Object catch (error) {
      throw StorageException('Failed to clear cache', cause: error);
    }
  }

  // Settings box operations

  Future<void> writeSetting(String key, dynamic value) async {
    _ensureInitialized();
    try {
      await _settingsBox!.put(key, value);
    } on Object catch (error) {
      throw StorageException('Failed to write setting: $key', cause: error);
    }
  }

  T? readSetting<T>(String key, {T? defaultValue}) {
    _ensureInitialized();
    try {
      final value = _settingsBox!.get(key, defaultValue: defaultValue);
      return value as T?;
    } on Object catch (error) {
      throw StorageException('Failed to read setting: $key', cause: error);
    }
  }

  Future<void> deleteSetting(String key) async {
    _ensureInitialized();
    try {
      await _settingsBox!.delete(key);
    } on Object catch (error) {
      throw StorageException('Failed to delete setting: $key', cause: error);
    }
  }

  // Secure storage operations

  Future<void> writeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } on Object catch (error) {
      throw StorageException('Failed to write secure key: $key', cause: error);
    }
  }

  Future<String?> readSecure(String key) async {
    try {
      return _secureStorage.read(key: key);
    } on Object catch (error) {
      throw StorageException('Failed to read secure key: $key', cause: error);
    }
  }

  Future<void> deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } on Object catch (error) {
      throw StorageException('Failed to delete secure key: $key', cause: error);
    }
  }

  Future<void> clearSecure() async {
    try {
      await _secureStorage.deleteAll();
    } on Object catch (error) {
      throw StorageException('Failed to clear secure storage', cause: error);
    }
  }

  /// Clears all local data (cache, settings, and secure storage).
  Future<void> clearAll() async {
    await clearCache();
    _ensureInitialized();
    await _settingsBox!.clear();
    await clearSecure();
    _logger.info('All local storage cleared');
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const StorageException(
        'StorageHelper not initialized. Call init() first.',
      );
    }
  }
}
