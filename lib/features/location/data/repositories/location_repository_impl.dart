import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/app_context.dart';
import '../../../../core/services/clock.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/prayer_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/city_search_local_data_source.dart';
import '../datasources/city_search_remote_data_source.dart';
import '../datasources/geocoding_data_source.dart';
import '../datasources/geolocator_location_data_source.dart';
import '../datasources/location_local_data_source.dart';

@LazySingleton(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl(
    this._geolocator,
    this._geocoding,
    this._remoteCities,
    this._localCities,
    this._cache,
    this._clock,
    this._appContext,
  );

  final GeolocatorLocationDataSource _geolocator;
  final GeocodingDataSource _geocoding;
  final CitySearchRemoteDataSource _remoteCities;
  final CitySearchLocalDataSource _localCities;
  final LocationLocalDataSource _cache;
  final Clock _clock;
  final AppContext _appContext;

  @override
  Future<Either<Failure, PrayerLocation>> getCurrent() async {
    try {
      await _geolocator.ensurePermission();

      Position? position;
      try {
        position = await _geolocator.current();
      } on LocationException catch (e) {
        // A fresh fix failed. The OS's stale fix, then the cache, are both
        // better than nothing: a slightly old position still produces a
        // schedule accurate to well under a minute.
        position = await _geolocator.lastKnown();
        if (position == null) {
          final cached = _cache.read();
          if (cached != null) return Right(cached);
          return Left(
            LocationFailure(message: e.message, isTimeout: e.isTimeout),
          );
        }
      }

      final located = PrayerLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        timeZoneId: _appContext.deviceTimeZoneId,
        method: LocationMethod.automatic,
        resolvedAt: _clock.now(),
      );

      final named = await _withResolvedName(located);
      await _persist(named);
      return Right(named);
    } on PermissionException catch (e) {
      return Left(
        PermissionFailure(
          message: e.message,
          isPermanentlyDenied: e.isPermanentlyDenied,
        ),
      );
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrayerLocation>> getCached() async {
    final cached = _cache.read();
    return cached == null
        ? const Left(CacheFailure(message: 'Belum ada lokasi tersimpan'))
        : Right(cached);
  }

  @override
  Future<Either<Failure, Unit>> saveLocation(PrayerLocation location) async {
    try {
      await _cache.write(location);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PrayerLocation>> setManualCity(City city) async {
    final location = PrayerLocation(
      latitude: city.latitude,
      longitude: city.longitude,
      // An online result with no inferable zone falls back to the device's.
      timeZoneId: city.timeZoneId.isEmpty
          ? _appContext.deviceTimeZoneId
          : city.timeZoneId,
      method: LocationMethod.manual,
      resolvedAt: _clock.now(),
      city: city.name,
      province: city.province,
      country: city.country,
    );

    await _persist(location);
    return Right(location);
  }

  @override
  Future<Either<Failure, PrayerLocation>> resolveName(
    PrayerLocation location,
  ) async {
    final named = await _withResolvedName(location);
    return Right(named);
  }

  @override
  Future<Either<Failure, List<City>>> searchCity(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return bundledCities();

    // Remote first for global coverage, local as the guaranteed fallback.
    // This is the standard pattern for every remote data source here.
    try {
      final remote = await _remoteCities.search(
        trimmed,
        languageCode: _appContext.languageCode,
      );
      if (remote.isNotEmpty) return Right(remote);
    } on Object {
      // Fall through to the bundled dataset.
    }

    try {
      return Right(await _localCities.search(trimmed));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<City>>> bundledCities() async {
    try {
      return Right(await _localCities.all());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> ensurePermission() async {
    try {
      await _geolocator.ensurePermission();
      return const Right(unit);
    } on PermissionException catch (e) {
      return Left(
        PermissionFailure(
          message: e.message,
          isPermanentlyDenied: e.isPermanentlyDenied,
        ),
      );
    }
  }

  @override
  double distanceBetween(PrayerLocation a, PrayerLocation b) => _geolocator
      .distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);

  /// Adds place names when geocoding is available, and returns the location
  /// unchanged when it is not.
  Future<PrayerLocation> _withResolvedName(PrayerLocation location) async {
    final placemark = await _geocoding.reverse(
      latitude: location.latitude,
      longitude: location.longitude,
      languageCode: _appContext.languageCode,
    );
    if (placemark == null) return location;

    final city =
        [
          placemark.subAdministrativeArea,
          placemark.locality,
          placemark.subLocality,
        ].firstWhere(
          (value) => value != null && value.isNotEmpty,
          orElse: () => null,
        );

    return location.copyWith(
      city: city,
      subAdmin: placemark.subAdministrativeArea,
      province: placemark.administrativeArea,
      country: placemark.country,
    );
  }

  Future<void> _persist(PrayerLocation location) async {
    try {
      await _cache.write(location);
    } on CacheException {
      // Losing the cache costs a re-fix on next launch; it must not fail the
      // call that produced a perfectly good location.
    }
  }
}
