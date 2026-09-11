import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';

/// Device positioning. The only file that imports `geolocator`.
abstract class GeolocatorLocationDataSource {
  /// Cheap: whatever fix the OS already has. Null when it has none.
  Future<Position?> lastKnown();

  /// Fresh fix, low accuracy, with a timeout.
  Future<Position> current();

  /// Grants or throws. Never silently returns a denied state.
  Future<void> ensurePermission();

  Future<bool> isServiceEnabled();

  Future<void> openAppSettings();

  Future<void> openLocationSettings();

  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );
}

@LazySingleton(as: GeolocatorLocationDataSource)
class GeolocatorLocationDataSourceImpl implements GeolocatorLocationDataSource {
  const GeolocatorLocationDataSourceImpl();

  /// City-level accuracy is plenty — a kilometre of error shifts prayer
  /// times by under a minute — and it costs far less battery than a GPS fix.
  static const LocationAccuracy _accuracy = LocationAccuracy.low;

  static const Duration _timeout = Duration(seconds: 10);

  @override
  Future<Position?> lastKnown() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } on Object {
      // Some OEMs throw instead of returning null. A missing cached fix is
      // not an error — the caller just asks for a fresh one.
      return null;
    }
  }

  @override
  Future<Position> current() async {
    await ensurePermission();

    // `isLocationServiceEnabled` is deliberately NOT used as a gate here.
    // On HyperOS it reports false while the OS itself reports location as
    // enabled, which blocked every fix on the test device. Ask for the
    // position and let the attempt decide; the service check is only used
    // afterwards, to phrase the failure correctly.
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: _accuracy,
          timeLimit: _timeout,
        ),
      );
    } on Object catch (e) {
      // A timeout is reported separately so the repository can fall back to
      // the cached location rather than pushing the user to manual entry.
      final isTimeout = e.toString().toLowerCase().contains('time');

      if (!isTimeout && !await isServiceEnabled()) {
        throw const LocationException(
          message: 'Layanan lokasi perangkat tidak aktif',
        );
      }

      throw LocationException(message: e.toString(), isTimeout: isTimeout);
    }
  }

  @override
  Future<void> ensurePermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const PermissionException(
        message: 'Izin lokasi ditolak permanen',
        isPermanentlyDenied: true,
      );
    }

    if (permission == LocationPermission.denied) {
      throw const PermissionException(message: 'Izin lokasi ditolak');
    }
  }

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) => Geolocator.distanceBetween(
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
  );
}
