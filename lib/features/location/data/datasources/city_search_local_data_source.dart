import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/city.dart';

/// The bundled Indonesian city dataset.
///
/// Exists so that picking a city works with no connection at all — the case
/// a user hits after denying location permission on a plane or in a dead
/// zone. Loaded once and kept in memory; the file is a few kilobytes.
abstract class CitySearchLocalDataSource {
  Future<List<City>> all();
  Future<List<City>> search(String query);
}

@LazySingleton(as: CitySearchLocalDataSource)
class CitySearchLocalDataSourceImpl implements CitySearchLocalDataSource {
  CitySearchLocalDataSourceImpl(this._bundle);

  final AssetBundle _bundle;

  static const String _assetPath = 'assets/data/cities_id.json';

  List<City>? _cache;

  @override
  Future<List<City>> all() async {
    final cached = _cache;
    if (cached != null) return cached;

    try {
      final raw = await _bundle.loadString(_assetPath);
      final decoded = jsonDecode(raw) as List<dynamic>;
      final cities = decoded
          .cast<Map<String, dynamic>>()
          .map(
            (json) => City(
              name: json['name'] as String,
              province: json['province'] as String?,
              latitude: (json['latitude'] as num).toDouble(),
              longitude: (json['longitude'] as num).toDouble(),
              timeZoneId: json['timeZoneId'] as String,
              country: 'Indonesia',
            ),
          )
          .toList(growable: false);

      _cache = cities;
      return cities;
    } on Object catch (e) {
      throw CacheException(message: 'Gagal memuat daftar kota: $e');
    }
  }

  @override
  Future<List<City>> search(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return all();

    final cities = await all();
    return cities
        .where(
          (c) =>
              c.name.toLowerCase().contains(trimmed) ||
              (c.province ?? '').toLowerCase().contains(trimmed),
        )
        .toList(growable: false);
  }
}
