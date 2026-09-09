import 'package:equatable/equatable.dart';

/// How the current location was obtained.
enum LocationMethod {
  /// Resolved from device GPS / network positioning.
  automatic,

  /// Picked by the user from the city list or search.
  manual;

  String get storageKey => name;

  static LocationMethod fromStorageKey(String? key) => values.firstWhere(
    (m) => m.storageKey == key,
    orElse: () => LocationMethod.automatic,
  );
}

/// A place to compute prayer times for.
///
/// [timeZoneId] travels with the coordinates on purpose: the schedule belongs
/// to the location's zone, not the device's, so picking a city in another
/// zone gives that city's real times.
class PrayerLocation extends Equatable {
  const PrayerLocation({
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
    required this.method,
    required this.resolvedAt,
    this.city,
    this.subAdmin,
    this.province,
    this.country,
  });

  final double latitude;
  final double longitude;

  /// IANA zone name, e.g. `Asia/Jakarta`.
  final String timeZoneId;

  final LocationMethod method;

  /// When the coordinates were obtained — used to decide whether a cached
  /// location is still worth showing while a fresh fix is pending.
  final DateTime resolvedAt;

  /// Reverse-geocoded names. All optional: geocoding needs a network, and a
  /// nameless location still produces a correct schedule.
  final String? city;
  final String? subAdmin;
  final String? province;
  final String? country;

  bool get isManual => method == LocationMethod.manual;

  bool get hasName => (city ?? '').isNotEmpty;

  /// Best label available, falling back to coordinates.
  String get displayName {
    if (hasName) {
      final region = subAdmin ?? province;
      return region == null || region.isEmpty || region == city
          ? city!
          : '$city, $region';
    }
    return '${latitude.toStringAsFixed(3)}, '
        '${longitude.toStringAsFixed(3)}';
  }

  PrayerLocation copyWith({
    double? latitude,
    double? longitude,
    String? timeZoneId,
    LocationMethod? method,
    DateTime? resolvedAt,
    String? city,
    String? subAdmin,
    String? province,
    String? country,
  }) {
    return PrayerLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      method: method ?? this.method,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      city: city ?? this.city,
      subAdmin: subAdmin ?? this.subAdmin,
      province: province ?? this.province,
      country: country ?? this.country,
    );
  }

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    timeZoneId,
    method,
    resolvedAt,
    city,
    subAdmin,
    province,
    country,
  ];
}
