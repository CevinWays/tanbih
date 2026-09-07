import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Connectivity probe used to fail fast instead of waiting for a timeout.
///
/// A `true` result only means the device has *a* connection — the request can
/// still fail. Treat it as a cheap pre-check, never as a guarantee.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any(
      (r) => r != ConnectivityResult.none && r != ConnectivityResult.bluetooth,
    );
  }
}
