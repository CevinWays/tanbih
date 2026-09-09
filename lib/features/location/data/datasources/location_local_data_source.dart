import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/prayer_location.dart';

/// Caches the last resolved location.
///
/// This is what makes the app work in airplane mode and on a cold start
/// before the first GPS fix arrives.
abstract class LocationLocalDataSource {
  PrayerLocation? read();
  Future<void> write(PrayerLocation location);
  Future<void> clear();
}

@LazySingleton(as: LocationLocalDataSource)
class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  LocationLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'location.last';

  @override
  PrayerLocation? read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return PrayerLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timeZoneId: json['time_zone_id'] as String,
        method: LocationMethod.fromStorageKey(json['method'] as String?),
        resolvedAt: DateTime.fromMillisecondsSinceEpoch(
          json['resolved_at'] as int,
        ),
        city: json['city'] as String?,
        subAdmin: json['sub_admin'] as String?,
        province: json['province'] as String?,
        country: json['country'] as String?,
      );
    } on Object {
      // A corrupt cache is indistinguishable from no cache as far as the
      // caller is concerned: it asks for a fresh fix either way.
      return null;
    }
  }

  @override
  Future<void> write(PrayerLocation location) async {
    final ok = await _prefs.setString(
      _key,
      jsonEncode({
        'latitude': location.latitude,
        'longitude': location.longitude,
        'time_zone_id': location.timeZoneId,
        'method': location.method.storageKey,
        'resolved_at': location.resolvedAt.millisecondsSinceEpoch,
        'city': location.city,
        'sub_admin': location.subAdmin,
        'province': location.province,
        'country': location.country,
      }),
    );
    if (!ok) throw const CacheException(message: 'Gagal menyimpan lokasi');
  }

  @override
  Future<void> clear() => _prefs.remove(_key).then((_) {});
}
