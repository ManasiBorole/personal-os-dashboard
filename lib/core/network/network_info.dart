/// Contract for checking network connectivity status.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;

  Stream<bool> get onConnectivityChanged;
}
