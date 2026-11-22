import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/features/qibla/domain/kaaba.dart';

void main() {
  group('distance to the Kaaba', () {
    test('matches published figures', () {
      // Malang is the reference the app was checked against on the test
      // device; the published figure there is 8,582 km.
      expect(
        Kaaba.distanceKmFrom(latitude: -7.9666, longitude: 112.6326),
        closeTo(8582, 2),
      );
      expect(
        Kaaba.distanceKmFrom(latitude: -6.2088, longitude: 106.8456),
        closeTo(7920, 10),
      );
      expect(
        Kaaba.distanceKmFrom(latitude: 51.5074, longitude: -0.1278),
        closeTo(4794, 10),
      );
    });

    test('is zero at the Kaaba itself', () {
      expect(
        Kaaba.distanceKmFrom(
          latitude: Kaaba.latitude,
          longitude: Kaaba.longitude,
        ),
        closeTo(0, 1e-9),
      );
    });

    test('is symmetric', () {
      const a = (lat: -7.9666, lon: 112.6326);
      const b = (lat: 51.5074, lon: -0.1278);

      expect(
        greatCircleDistanceKm(
          fromLatitude: a.lat,
          fromLongitude: a.lon,
          toLatitude: b.lat,
          toLongitude: b.lon,
        ),
        closeTo(
          greatCircleDistanceKm(
            fromLatitude: b.lat,
            fromLongitude: b.lon,
            toLatitude: a.lat,
            toLongitude: a.lon,
          ),
          1e-9,
        ),
      );
    });

    test('never exceeds half the circumference', () {
      for (var lat = -90.0; lat <= 90; lat += 15) {
        for (var lon = -180.0; lon <= 180; lon += 15) {
          expect(
            Kaaba.distanceKmFrom(latitude: lat, longitude: lon),
            lessThanOrEqualTo(20015),
          );
        }
      }
    });
  });
}
