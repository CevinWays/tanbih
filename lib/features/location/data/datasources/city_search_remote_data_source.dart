import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/city.dart';

/// Online city search, for places outside the bundled Indonesian dataset.
///
/// Enhancement only: every caller must be able to continue with the local
/// dataset when this fails. Nothing in the prayer schedule depends on it.
abstract class CitySearchRemoteDataSource {
  Future<List<City>> search(String query, {required String languageCode});
}

@LazySingleton(as: CitySearchRemoteDataSource)
class CitySearchRemoteDataSourceImpl implements CitySearchRemoteDataSource {
  CitySearchRemoteDataSourceImpl(this._dio, this._networkInfo);

  final Dio _dio;
  final NetworkInfo _networkInfo;

  static const int _limit = 8;

  @override
  Future<List<City>> search(
    String query, {
    required String languageCode,
  }) async {
    // Fail fast rather than making the user wait out a 15-second timeout
    // just to fall back to the bundled list.
    if (!await _networkInfo.isConnected) {
      throw const NetworkException();
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '${AppConfig.geocodingBaseUrl}/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': _limit,
          'addressdetails': 1,
          'accept-language': languageCode,
        },
      );

      final results = response.data ?? const [];
      return results
          .cast<Map<String, dynamic>>()
          .map(_toCity)
          .whereType<City>()
          .toList(growable: false);
    } on DioException catch (e) {
      // ErrorInterceptor has already mapped this; carry the Failure through
      // so the repository does not have to re-interpret Dio's error types.
      final mapped = e.error;
      if (mapped is NetworkFailure) throw const NetworkException();
      if (mapped is ServerFailure) {
        throw ServerException(
          message: mapped.message,
          statusCode: mapped.statusCode,
        );
      }
      throw ServerException(message: e.message ?? 'Pencarian kota gagal');
    }
  }

  City? _toCity(Map<String, dynamic> json) {
    final lat = double.tryParse('${json['lat']}');
    final lon = double.tryParse('${json['lon']}');
    if (lat == null || lon == null) return null;

    final address = (json['address'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = _pickName(json, address);
    if (name == null || name.isEmpty) return null;

    final countryCode = (address['country_code'] as String?)?.toUpperCase();

    return City(
      name: name,
      province: address['state'] as String?,
      country: address['country'] as String?,
      latitude: lat,
      longitude: lon,
      timeZoneId: _inferTimeZone(countryCode, lon),
    );
  }

  String? _pickName(Map<String, dynamic> json, Map<String, dynamic> address) {
    for (final key in const ['city', 'town', 'municipality', 'village']) {
      final value = address[key];
      if (value is String && value.isNotEmpty) return value;
    }
    // Fall back to the first comma-separated part of the display name.
    final display = json['display_name'];
    if (display is String && display.isNotEmpty) {
      return display.split(',').first.trim();
    }
    return null;
  }

  /// Nominatim does not return a time zone.
  ///
  /// For Indonesian results the zone follows directly from longitude, which
  /// is exact because the three national zones are defined by province
  /// groupings that align with these meridians. Outside Indonesia there is
  /// no safe inference, so the caller is told to keep the device zone by
  /// receiving [unknownTimeZone].
  static String _inferTimeZone(String? countryCode, double longitude) {
    if (countryCode != 'ID') return unknownTimeZone;
    if (longitude < 115) return 'Asia/Jakarta';
    if (longitude < 135) return 'Asia/Makassar';
    return 'Asia/Jayapura';
  }

  /// Sentinel meaning "no zone could be determined for this place".
  ///
  /// The repository substitutes the device zone and the UI warns the user
  /// that times may be off for a distant city.
  static const String unknownTimeZone = '';
}
