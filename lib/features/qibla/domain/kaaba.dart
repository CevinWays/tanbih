import 'dart:math' as math;

/// The Kaaba, and how far away it is.
///
/// Plain Dart: no package, no `Either`. Unlike the qibla *bearing*, which
/// comes out of the `adhan` package and therefore lives behind a repository,
/// a great-circle distance is arithmetic that cannot fail.
abstract final class Kaaba {
  /// Masjid al-Haram, Makkah.
  static const double latitude = 21.4225;
  static const double longitude = 39.8262;

  /// IUGG mean Earth radius, in kilometres.
  ///
  /// Haversine on a sphere differs from the ellipsoidal answer by well under
  /// 1% at these distances — three orders of magnitude finer than a figure
  /// rounded to whole kilometres.
  static const double meanEarthRadiusKm = 6371.0088;

  /// Great-circle distance from a position to the Kaaba, in kilometres.
  static double distanceKmFrom({
    required double latitude,
    required double longitude,
  }) => greatCircleDistanceKm(
    fromLatitude: latitude,
    fromLongitude: longitude,
    toLatitude: Kaaba.latitude,
    toLongitude: Kaaba.longitude,
  );
}

/// Great-circle distance between two points, in kilometres.
///
/// The `asin(sqrt(h))` form of the haversine, which stays accurate for very
/// small separations where the law-of-cosines form loses precision.
double greatCircleDistanceKm({
  required double fromLatitude,
  required double fromLongitude,
  required double toLatitude,
  required double toLongitude,
}) {
  final phi1 = _radians(fromLatitude);
  final phi2 = _radians(toLatitude);
  final deltaPhi = _radians(toLatitude - fromLatitude);
  final deltaLambda = _radians(toLongitude - fromLongitude);

  final h =
      math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
      math.cos(phi1) *
          math.cos(phi2) *
          math.sin(deltaLambda / 2) *
          math.sin(deltaLambda / 2);

  return 2 * Kaaba.meanEarthRadiusKm * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
}

double _radians(double degrees) => degrees * math.pi / 180;
