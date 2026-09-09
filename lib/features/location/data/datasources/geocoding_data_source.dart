import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';

/// Reverse geocoding through the platform's own service.
///
/// Best-effort by design: the returned names are decoration, and every
/// failure resolves to null rather than an exception, because a nameless
/// location still yields a correct prayer schedule.
abstract class GeocodingDataSource {
  Future<Placemark?> reverse({
    required double latitude,
    required double longitude,
    required String languageCode,
  });
}

@LazySingleton(as: GeocodingDataSource)
class GeocodingDataSourceImpl implements GeocodingDataSource {
  const GeocodingDataSourceImpl();

  @override
  Future<Placemark?> reverse({
    required double latitude,
    required double longitude,
    required String languageCode,
  }) async {
    try {
      await setLocaleIdentifier(languageCode);
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      return placemarks.isEmpty ? null : placemarks.first;
    } on Object {
      return null;
    }
  }
}
