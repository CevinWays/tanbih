import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/error/exceptions.dart';
import 'package:tanbih/core/error/failures.dart';
import 'package:tanbih/core/services/app_context.dart';
import 'package:tanbih/core/services/clock.dart';
import 'package:tanbih/features/location/data/datasources/city_search_local_data_source.dart';
import 'package:tanbih/features/location/data/datasources/city_search_remote_data_source.dart';
import 'package:tanbih/features/location/data/datasources/geocoding_data_source.dart';
import 'package:tanbih/features/location/data/datasources/geolocator_location_data_source.dart';
import 'package:tanbih/features/location/data/datasources/location_local_data_source.dart';
import 'package:tanbih/features/location/data/repositories/location_repository_impl.dart';
import 'package:tanbih/features/location/domain/entities/city.dart';
import 'package:tanbih/features/location/domain/entities/prayer_location.dart';

class MockGeolocator extends Mock implements GeolocatorLocationDataSource {}

class MockGeocoding extends Mock implements GeocodingDataSource {}

class MockRemoteCities extends Mock implements CitySearchRemoteDataSource {}

class MockLocalCities extends Mock implements CitySearchLocalDataSource {}

class MockCache extends Mock implements LocationLocalDataSource {}

Position _position(double lat, double lng) => Position(
  latitude: lat,
  longitude: lng,
  timestamp: DateTime(2026, 9, 7),
  accuracy: 100,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  late MockGeolocator geolocator;
  late MockGeocoding geocoding;
  late MockRemoteCities remoteCities;
  late MockLocalCities localCities;
  late MockCache cache;
  late AppContext appContext;
  late FakeClock clock;
  late LocationRepositoryImpl repository;

  final cached = PrayerLocation(
    latitude: -6.2,
    longitude: 106.8,
    timeZoneId: 'Asia/Jakarta',
    method: LocationMethod.automatic,
    resolvedAt: DateTime(2026, 9, 6),
    city: 'Jakarta',
  );

  setUpAll(() => registerFallbackValue(cached));

  setUp(() {
    geolocator = MockGeolocator();
    geocoding = MockGeocoding();
    remoteCities = MockRemoteCities();
    localCities = MockLocalCities();
    cache = MockCache();
    appContext = AppContext();
    clock = FakeClock(DateTime(2026, 9, 7, 10));
    repository = LocationRepositoryImpl(
      geolocator,
      geocoding,
      remoteCities,
      localCities,
      cache,
      clock,
      appContext,
    );

    when(() => geolocator.ensurePermission()).thenAnswer((_) async {});
    when(() => cache.write(any())).thenAnswer((_) async {});
    when(() => cache.read()).thenReturn(null);
    when(
      () => geocoding.reverse(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async => null);
  });

  group('getCurrent', () {
    test('uses a fresh fix and stamps the device zone', () async {
      when(
        () => geolocator.current(),
      ).thenAnswer((_) async => _position(-6.2088, 106.8456));
      appContext.deviceTimeZoneId = 'Asia/Makassar';

      final result = await repository.getCurrent();
      final location = result.getOrElse(() => cached);

      expect(location.latitude, -6.2088);
      expect(location.timeZoneId, 'Asia/Makassar');
      expect(location.method, LocationMethod.automatic);
      expect(location.resolvedAt, clock.now());
      verify(() => cache.write(any())).called(1);
    });

    test(
      'falls back to the last known fix when a fresh one times out',
      () async {
        when(
          () => geolocator.current(),
        ).thenThrow(const LocationException(isTimeout: true));
        when(
          () => geolocator.lastKnown(),
        ).thenAnswer((_) async => _position(-6.1, 106.7));

        final result = await repository.getCurrent();

        expect(result.getOrElse(() => cached).latitude, -6.1);
      },
    );

    test('falls back to the cache when there is no fix at all', () async {
      when(
        () => geolocator.current(),
      ).thenThrow(const LocationException(isTimeout: true));
      when(() => geolocator.lastKnown()).thenAnswer((_) async => null);
      when(cache.read).thenReturn(cached);

      final result = await repository.getCurrent();

      expect(result.getOrElse(() => cached), cached);
    });

    test('fails only when there is no fix and no cache', () async {
      when(
        () => geolocator.current(),
      ).thenThrow(const LocationException(message: 'no signal'));
      when(() => geolocator.lastKnown()).thenAnswer((_) async => null);

      final result = await repository.getCurrent();

      expect(result.fold((f) => f, (_) => null), isA<LocationFailure>());
    });

    test('reports a permanent denial distinctly', () async {
      when(
        () => geolocator.ensurePermission(),
      ).thenThrow(const PermissionException(isPermanentlyDenied: true));

      final result = await repository.getCurrent();

      expect(
        result.fold((f) => f, (_) => null),
        isA<PermissionFailure>().having(
          (f) => f.isPermanentlyDenied,
          'permanent',
          isTrue,
        ),
      );
    });

    test('a geocoding failure still yields a usable location', () async {
      when(
        () => geolocator.current(),
      ).thenAnswer((_) async => _position(-6.2088, 106.8456));
      when(
        () => geocoding.reverse(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async => null);

      final result = await repository.getCurrent();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => cached).hasName, isFalse);
    });

    test('a cache write failure does not fail the call', () async {
      when(
        () => geolocator.current(),
      ).thenAnswer((_) async => _position(-6.2088, 106.8456));
      when(
        () => cache.write(any()),
      ).thenThrow(const CacheException(message: 'disk full'));

      expect((await repository.getCurrent()).isRight(), isTrue);
    });

    test('attaches reverse-geocoded names when available', () async {
      when(
        () => geolocator.current(),
      ).thenAnswer((_) async => _position(-6.2088, 106.8456));
      when(
        () => geocoding.reverse(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer(
        (_) async => const Placemark(
          locality: 'Jakarta Selatan',
          subAdministrativeArea: 'Jakarta Selatan',
          administrativeArea: 'DKI Jakarta',
          country: 'Indonesia',
        ),
      );

      final location = (await repository.getCurrent()).getOrElse(() => cached);

      expect(location.city, 'Jakarta Selatan');
      expect(location.province, 'DKI Jakarta');
    });
  });

  group('setManualCity', () {
    test('keeps the city zone and marks the location manual', () async {
      const city = City(
        name: 'Makassar',
        latitude: -5.1343,
        longitude: 119.4124,
        timeZoneId: 'Asia/Makassar',
        province: 'Sulawesi Selatan',
      );

      final location = (await repository.setManualCity(
        city,
      )).getOrElse(() => cached);

      expect(location.timeZoneId, 'Asia/Makassar');
      expect(location.isManual, isTrue);
      expect(location.city, 'Makassar');
    });

    test('substitutes the device zone when the city has none', () async {
      // Online results carry no time zone; the repository must not leave it
      // empty, which would make the calculator throw.
      appContext.deviceTimeZoneId = 'Asia/Jakarta';
      const city = City(
        name: 'Kuala Lumpur',
        latitude: 3.139,
        longitude: 101.6869,
        timeZoneId: '',
        country: 'Malaysia',
      );

      final location = (await repository.setManualCity(
        city,
      )).getOrElse(() => cached);

      expect(location.timeZoneId, 'Asia/Jakarta');
    });
  });

  group('searchCity', () {
    const remoteHit = City(
      name: 'Cairo',
      latitude: 30.0,
      longitude: 31.2,
      timeZoneId: '',
      country: 'Egypt',
    );
    const localHit = City(
      name: 'Bandung',
      latitude: -6.9,
      longitude: 107.6,
      timeZoneId: 'Asia/Jakarta',
    );

    test('prefers remote results', () async {
      when(
        () => remoteCities.search(
          any(),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async => [remoteHit]);

      final cities = (await repository.searchCity('cairo')).getOrElse(() => []);

      expect(cities, [remoteHit]);
      verifyNever(() => localCities.search(any()));
    });

    test('falls back to the bundled dataset when remote fails', () async {
      when(
        () => remoteCities.search(
          any(),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenThrow(const NetworkException());
      when(() => localCities.search(any())).thenAnswer((_) async => [localHit]);

      final cities = (await repository.searchCity(
        'bandung',
      )).getOrElse(() => []);

      expect(cities, [localHit]);
    });

    test('falls back when remote returns nothing', () async {
      when(
        () => remoteCities.search(
          any(),
          languageCode: any(named: 'languageCode'),
        ),
      ).thenAnswer((_) async => []);
      when(() => localCities.search(any())).thenAnswer((_) async => [localHit]);

      expect((await repository.searchCity('bandung')).getOrElse(() => []), [
        localHit,
      ]);
    });

    test(
      'an empty query lists the bundled cities without hitting network',
      () async {
        when(localCities.all).thenAnswer((_) async => [localHit]);

        final cities = (await repository.searchCity('  ')).getOrElse(() => []);

        expect(cities, [localHit]);
        verifyNever(
          () => remoteCities.search(
            any(),
            languageCode: any(named: 'languageCode'),
          ),
        );
      },
    );
  });

  group('distanceBetween', () {
    test('delegates to the platform implementation', () {
      when(
        () => geolocator.distanceBetween(any(), any(), any(), any()),
      ).thenReturn(5200);

      expect(repository.distanceBetween(cached, cached), 5200);
    });
  });
}
