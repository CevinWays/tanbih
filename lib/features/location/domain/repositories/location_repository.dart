import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/city.dart';
import '../entities/prayer_location.dart';

abstract class LocationRepository {
  /// Best available position right now.
  ///
  /// Tries the OS's last known fix first so the UI can render immediately,
  /// then a fresh low-accuracy fix. City-level precision is enough: a
  /// kilometre of error moves prayer times by well under a minute.
  Future<Either<Failure, PrayerLocation>> getCurrent();

  /// Last location that was stored, if any. Always offline.
  Future<Either<Failure, PrayerLocation>> getCached();

  Future<Either<Failure, Unit>> saveLocation(PrayerLocation location);

  /// Adopt a city the user picked.
  Future<Either<Failure, PrayerLocation>> setManualCity(City city);

  /// Reverse-geocode a name for the coordinates. Needs a network; failure is
  /// non-fatal because the schedule does not depend on the name.
  Future<Either<Failure, PrayerLocation>> resolveName(PrayerLocation location);

  /// Search online first, then fall back to the bundled Indonesian dataset.
  Future<Either<Failure, List<City>>> searchCity(String query);

  /// Whole bundled dataset, for browsing without typing.
  Future<Either<Failure, List<City>>> bundledCities();

  /// Ensure the OS-level location permission is granted, prompting if it has
  /// not been asked yet.
  Future<Either<Failure, Unit>> ensurePermission();

  /// Metres between two locations — used to decide whether the notification
  /// schedule has to be rebuilt.
  double distanceBetween(PrayerLocation a, PrayerLocation b);
}
