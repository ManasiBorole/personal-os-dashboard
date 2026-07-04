import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:personal_os_dashboard/core/network/network_info.dart';

/// Connectivity-backed implementation of [NetworkInfo].
final class ConnectivityService implements NetworkInfo {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnectedResult(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnectedResult);
  }

  bool _isConnectedResult(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
