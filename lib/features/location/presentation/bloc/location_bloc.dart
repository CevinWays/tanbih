import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/prayer_location.dart';
import '../../domain/usecases/get_cached_location.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/search_city.dart';
import '../../domain/usecases/set_manual_city.dart';
import 'location_event.dart';
import 'location_state.dart';

/// Owns the location the schedule is computed for.
@injectable
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc(
    this._getCurrentLocation,
    this._getCachedLocation,
    this._setManualCity,
    this._searchCity,
  ) : super(const LocationState()) {
    on<LocationStartupRequested>(_onStartupRequested);
    on<LocationRefreshRequested>(_onRefreshRequested);
    on<LocationCitySelected>(_onCitySelected);
    // Typing produces an event per keystroke; debounce and drop anything
    // superseded so only the last query is actually searched.
    on<LocationCitySearchChanged>(_onSearchChanged, transformer: restartable());
    on<LocationCitySearchCleared>(_onSearchCleared);
  }

  final GetCurrentLocation _getCurrentLocation;
  final GetCachedLocation _getCachedLocation;
  final SetManualCity _setManualCity;
  final SearchCity _searchCity;

  static const Duration _searchDebounce = Duration(milliseconds: 400);

  Future<void> _onStartupRequested(
    LocationStartupRequested event,
    Emitter<LocationState> emit,
  ) async {
    final cached = await _getCachedLocation(const NoParams());

    final cachedLocation = cached.fold<PrayerLocation?>(
      (_) => null,
      (location) => location,
    );

    if (cachedLocation != null) {
      // Render immediately from cache. This is what makes a cold start (and
      // airplane mode) show a schedule right away.
      emit(
        state.copyWith(
          status: LocationStatus.success,
          location: cachedLocation,
          clearFailure: true,
          // A manually chosen city is the user's explicit decision — never
          // silently replace it with a GPS fix.
          isRefreshing: !cachedLocation.isManual,
        ),
      );

      if (cachedLocation.isManual) return;
      await _resolveFresh(emit, keepExisting: true);
      return;
    }

    emit(state.copyWith(status: LocationStatus.resolving, clearFailure: true));
    await _resolveFresh(emit, keepExisting: false);
  }

  Future<void> _onRefreshRequested(
    LocationRefreshRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: state.hasLocation
            ? LocationStatus.success
            : LocationStatus.resolving,
        isRefreshing: true,
        clearFailure: true,
      ),
    );
    await _resolveFresh(emit, keepExisting: state.hasLocation);
  }

  Future<void> _onCitySelected(
    LocationCitySelected event,
    Emitter<LocationState> emit,
  ) async {
    final result = await _setManualCity(event.city);

    emit(
      result.fold(
        (failure) => state.copyWith(
          status: state.hasLocation
              ? LocationStatus.success
              : LocationStatus.failure,
          failure: failure,
        ),
        (location) => state.copyWith(
          status: LocationStatus.success,
          location: location,
          isRefreshing: false,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> _onSearchChanged(
    LocationCitySearchChanged event,
    Emitter<LocationState> emit,
  ) async {
    final query = event.query.trim();

    emit(
      state.copyWith(
        searchQuery: event.query,
        searchStatus: CitySearchStatus.loading,
      ),
    );

    await Future<void>.delayed(_searchDebounce);

    // `restartable()` cancels the emitter when a newer keystroke arrives,
    // but it cannot kill this already-running handler — without this guard
    // every keystroke would still reach the network, and the debounce would
    // only be hiding the results.
    if (emit.isDone) return;

    final result = await _searchCity(query);
    if (emit.isDone) return;

    emit(
      result.fold(
        (failure) => state.copyWith(
          searchStatus: CitySearchStatus.failure,
          failure: failure,
        ),
        (cities) => state.copyWith(
          searchStatus: CitySearchStatus.success,
          searchResults: cities,
        ),
      ),
    );
  }

  Future<void> _onSearchCleared(
    LocationCitySearchCleared event,
    Emitter<LocationState> emit,
  ) async {
    emit(
      state.copyWith(searchQuery: '', searchStatus: CitySearchStatus.loading),
    );

    final result = await _searchCity('');

    emit(
      result.fold(
        (failure) => state.copyWith(
          searchStatus: CitySearchStatus.failure,
          failure: failure,
        ),
        (cities) => state.copyWith(
          searchStatus: CitySearchStatus.success,
          searchResults: cities,
        ),
      ),
    );
  }

  Future<void> _resolveFresh(
    Emitter<LocationState> emit, {
    required bool keepExisting,
  }) async {
    final result = await _getCurrentLocation(const NoParams());

    emit(
      result.fold(
        (failure) => state.copyWith(
          // Failing to refresh must not throw away a location that is
          // already good enough to compute with.
          status: keepExisting && state.hasLocation
              ? LocationStatus.success
              : LocationStatus.failure,
          failure: failure,
          isRefreshing: false,
        ),
        (location) => state.copyWith(
          status: LocationStatus.success,
          location: location,
          isRefreshing: false,
          clearFailure: true,
        ),
      ),
    );
  }
}
