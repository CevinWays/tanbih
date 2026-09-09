import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/error/failures.dart';
import 'package:tanbih/core/usecases/usecase.dart';
import 'package:tanbih/features/location/domain/entities/city.dart';
import 'package:tanbih/features/location/domain/entities/prayer_location.dart';
import 'package:tanbih/features/location/domain/usecases/get_cached_location.dart';
import 'package:tanbih/features/location/domain/usecases/get_current_location.dart';
import 'package:tanbih/features/location/domain/usecases/search_city.dart';
import 'package:tanbih/features/location/domain/usecases/set_manual_city.dart';
import 'package:tanbih/features/location/presentation/bloc/location_bloc.dart';
import 'package:tanbih/features/location/presentation/bloc/location_event.dart';
import 'package:tanbih/features/location/presentation/bloc/location_state.dart';

class MockGetCurrent extends Mock implements GetCurrentLocation {}

class MockGetCached extends Mock implements GetCachedLocation {}

class MockSetManualCity extends Mock implements SetManualCity {}

class MockSearchCity extends Mock implements SearchCity {}

void main() {
  late MockGetCurrent getCurrent;
  late MockGetCached getCached;
  late MockSetManualCity setManualCity;
  late MockSearchCity searchCity;

  final fresh = PrayerLocation(
    latitude: -6.2088,
    longitude: 106.8456,
    timeZoneId: 'Asia/Jakarta',
    method: LocationMethod.automatic,
    resolvedAt: DateTime(2026, 9, 7),
    city: 'Jakarta',
  );

  final cachedAuto = fresh.copyWith(
    resolvedAt: DateTime(2026, 9, 6),
    city: 'Bogor',
  );

  final cachedManual = PrayerLocation(
    latitude: -5.1343,
    longitude: 119.4124,
    timeZoneId: 'Asia/Makassar',
    method: LocationMethod.manual,
    resolvedAt: DateTime(2026, 9, 6),
    city: 'Makassar',
  );

  const bandung = City(
    name: 'Bandung',
    latitude: -6.9218,
    longitude: 107.6071,
    timeZoneId: 'Asia/Jakarta',
    province: 'Jawa Barat',
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(bandung);
  });

  setUp(() {
    getCurrent = MockGetCurrent();
    getCached = MockGetCached();
    setManualCity = MockSetManualCity();
    searchCity = MockSearchCity();

    when(() => getCurrent(any())).thenAnswer((_) async => Right(fresh));
    when(
      () => getCached(any()),
    ).thenAnswer((_) async => const Left(CacheFailure()));
    when(() => setManualCity(any())).thenAnswer(
      (_) async => Right(
        PrayerLocation(
          latitude: bandung.latitude,
          longitude: bandung.longitude,
          timeZoneId: bandung.timeZoneId,
          method: LocationMethod.manual,
          resolvedAt: DateTime(2026, 9, 7),
          city: bandung.name,
        ),
      ),
    );
    when(() => searchCity(any())).thenAnswer((_) async => const Right([]));
  });

  LocationBloc build() =>
      LocationBloc(getCurrent, getCached, setManualCity, searchCity);

  group('startup', () {
    blocTest<LocationBloc, LocationState>(
      'with no cache it resolves a fresh location',
      build: build,
      act: (bloc) => bloc.add(const LocationStartupRequested()),
      expect: () => [
        isA<LocationState>().having(
          (s) => s.status,
          'status',
          LocationStatus.resolving,
        ),
        isA<LocationState>()
            .having((s) => s.status, 'status', LocationStatus.success)
            .having((s) => s.location, 'location', fresh),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'shows the cached location first, then refreshes it',
      setUp: () => when(
        () => getCached(any()),
      ).thenAnswer((_) async => Right(cachedAuto)),
      build: build,
      act: (bloc) => bloc.add(const LocationStartupRequested()),
      expect: () => [
        // Rendered immediately so a cold start is not a blank screen.
        isA<LocationState>()
            .having((s) => s.location, 'location', cachedAuto)
            .having((s) => s.isRefreshing, 'isRefreshing', isTrue),
        isA<LocationState>()
            .having((s) => s.location, 'location', fresh)
            .having((s) => s.isRefreshing, 'isRefreshing', isFalse),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'never overrides a manually chosen city with GPS',
      setUp: () => when(
        () => getCached(any()),
      ).thenAnswer((_) async => Right(cachedManual)),
      build: build,
      act: (bloc) => bloc.add(const LocationStartupRequested()),
      expect: () => [
        isA<LocationState>()
            .having((s) => s.location, 'location', cachedManual)
            .having((s) => s.isRefreshing, 'isRefreshing', isFalse),
      ],
      verify: (_) => verifyNever(() => getCurrent(any())),
    );

    blocTest<LocationBloc, LocationState>(
      'a refresh failure keeps the cached location usable',
      setUp: () {
        when(() => getCached(any())).thenAnswer((_) async => Right(cachedAuto));
        when(
          () => getCurrent(any()),
        ).thenAnswer((_) async => const Left(LocationFailure()));
      },
      build: build,
      act: (bloc) => bloc.add(const LocationStartupRequested()),
      skip: 1,
      expect: () => [
        isA<LocationState>()
            .having((s) => s.status, 'status', LocationStatus.success)
            .having((s) => s.location, 'keeps cache', cachedAuto)
            .having((s) => s.failure, 'reports the failure', isNotNull),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'a permanent denial with no cache surfaces as failure',
      setUp: () => when(() => getCurrent(any())).thenAnswer(
        (_) async => const Left(PermissionFailure(isPermanentlyDenied: true)),
      ),
      build: build,
      act: (bloc) => bloc.add(const LocationStartupRequested()),
      skip: 1,
      expect: () => [
        isA<LocationState>()
            .having((s) => s.status, 'status', LocationStatus.failure)
            .having((s) => s.isPermanentlyDenied, 'permanent', isTrue),
      ],
    );
  });

  group('manual city', () {
    blocTest<LocationBloc, LocationState>(
      'selecting a city adopts it and clears any failure',
      build: build,
      seed: () => const LocationState(
        status: LocationStatus.failure,
        failure: PermissionFailure(isPermanentlyDenied: true),
      ),
      act: (bloc) => bloc.add(const LocationCitySelected(bandung)),
      expect: () => [
        isA<LocationState>()
            .having((s) => s.status, 'status', LocationStatus.success)
            .having((s) => s.location?.city, 'city', 'Bandung')
            .having((s) => s.failure, 'failure', isNull),
      ],
    );
  });

  group('search', () {
    blocTest<LocationBloc, LocationState>(
      'debounces and returns results',
      build: build,
      setUp: () => when(
        () => searchCity(any()),
      ).thenAnswer((_) async => const Right([bandung])),
      act: (bloc) => bloc.add(const LocationCitySearchChanged('band')),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        isA<LocationState>().having(
          (s) => s.searchStatus,
          'status',
          CitySearchStatus.loading,
        ),
        isA<LocationState>()
            .having((s) => s.searchStatus, 'status', CitySearchStatus.success)
            .having((s) => s.searchResults, 'results', [bandung]),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'only the last keystroke is searched',
      build: build,
      setUp: () => when(
        () => searchCity(any()),
      ).thenAnswer((_) async => const Right([bandung])),
      act: (bloc) => bloc
        ..add(const LocationCitySearchChanged('b'))
        ..add(const LocationCitySearchChanged('ba'))
        ..add(const LocationCitySearchChanged('ban')),
      wait: const Duration(milliseconds: 700),
      verify: (_) {
        // Superseded keystrokes are cancelled before the debounce elapses,
        // so exactly one request reaches the network.
        verify(() => searchCity('ban')).called(1);
        verifyNever(() => searchCity('b'));
        verifyNever(() => searchCity('ba'));
      },
    );

    blocTest<LocationBloc, LocationState>(
      'clearing the query reloads the full list',
      build: build,
      setUp: () => when(
        () => searchCity(''),
      ).thenAnswer((_) async => const Right([bandung])),
      act: (bloc) => bloc.add(const LocationCitySearchCleared()),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<LocationState>().having((s) => s.searchQuery, 'query', ''),
        isA<LocationState>()
            .having((s) => s.searchStatus, 'status', CitySearchStatus.success)
            .having((s) => s.searchResults, 'results', [bandung]),
      ],
    );
  });
}
