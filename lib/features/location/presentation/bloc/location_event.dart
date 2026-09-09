import 'package:equatable/equatable.dart';

import '../../domain/entities/city.dart';

sealed class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

/// Startup path: show the cached location at once, then refresh in the
/// background if the location is automatic.
final class LocationStartupRequested extends LocationEvent {
  const LocationStartupRequested();
}

/// Explicit "use my location" — from onboarding or the location picker.
final class LocationRefreshRequested extends LocationEvent {
  const LocationRefreshRequested();
}

final class LocationCitySelected extends LocationEvent {
  const LocationCitySelected(this.city);

  final City city;

  @override
  List<Object?> get props => [city];
}

final class LocationCitySearchChanged extends LocationEvent {
  const LocationCitySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Reopen the picker's initial list.
final class LocationCitySearchCleared extends LocationEvent {
  const LocationCitySearchCleared();
}
