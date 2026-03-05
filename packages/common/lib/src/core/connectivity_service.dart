import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityService {
  /// Returns true if there is an active network connection.
  Future<bool> isOnline();

  /// Emits true when connected, false when disconnected.
  Stream<bool> get onConnectivityChanged;
}

class ConnectivityPlusService implements ConnectivityService {
  final _connectivity = Connectivity();

  static bool _isConnected(List<ConnectivityResult> results) =>
      results.isNotEmpty && !results.contains(ConnectivityResult.none);

  @override
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnected);
  }
}
