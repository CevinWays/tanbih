import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/prayer_location.dart';

enum LocationStatus {
  initial,

  /// Asking the OS for permission, or waiting on a fix.
  resolving,

  /// A usable location is available — fresh or cached.
  success,

  /// Nothing usable. [LocationState.failure] says why, and the UI offers
  /// manual selection.
  failure,
}

enum CitySearchStatus { initial, loading, success, failure }

class LocationState extends Equatable {
  const LocationState({
    this.status = LocationStatus.initial,
    this.location,
    this.failure,
    this.searchStatus = CitySearchStatus.initial,
    this.searchResults = const [],
    this.searchQuery = '',
    this.isRefreshing = false,
  });

  final LocationStatus status;
  final PrayerLocation? location;
  final Failure? failure;

  final CitySearchStatus searchStatus;
  final List<City> searchResults;
  final String searchQuery;

  /// A fresh fix is being fetched while a cached location is already shown.
  /// Lets the UI show a subtle indicator instead of a blocking spinner.
  final bool isRefreshing;

  bool get hasLocation => location != null;

  /// True when permission was denied for good, so the UI must point at
  /// system settings rather than asking again.
  bool get isPermanentlyDenied =>
      failure is PermissionFailure &&
      (failure as PermissionFailure).isPermanentlyDenied;

  /// A manually chosen city whose zone had to be substituted with the
  /// device's — times may be wrong for a distant place, so warn.
  bool get needsTimeZoneWarning {
    final current = location;
    return current != null &&
        current.isManual &&
        current.country != 'Indonesia';
  }

  LocationState copyWith({
    LocationStatus? status,
    PrayerLocation? location,
    Failure? failure,
    bool clearFailure = false,
    CitySearchStatus? searchStatus,
    List<City>? searchResults,
    String? searchQuery,
    bool? isRefreshing,
  }) {
    return LocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      failure: clearFailure ? null : (failure ?? this.failure),
      searchStatus: searchStatus ?? this.searchStatus,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    status,
    location,
    failure,
    searchStatus,
    searchResults,
    searchQuery,
    isRefreshing,
  ];
}
