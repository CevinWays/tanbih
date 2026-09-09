import 'package:equatable/equatable.dart';

/// A searchable place, from the bundled dataset or from online search.
class City extends Equatable {
  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
    this.province,
    this.country,
  });

  final String name;
  final double latitude;
  final double longitude;

  /// IANA zone. For bundled Indonesian cities this is authoritative; for
  /// online results it is inferred, so it can be wrong near a zone border.
  final String timeZoneId;

  final String? province;
  final String? country;

  String get displayName =>
      province == null || province!.isEmpty ? name : '$name, $province';

  @override
  List<Object?> get props => [
    name,
    latitude,
    longitude,
    timeZoneId,
    province,
    country,
  ];
}
