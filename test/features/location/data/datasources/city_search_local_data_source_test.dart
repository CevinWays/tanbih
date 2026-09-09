import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/features/location/data/datasources/city_search_local_data_source.dart';

/// Serves the real bundled asset so the shipped dataset itself is validated,
/// not a hand-written stand-in.
class _RealAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final file = File('assets/data/cities_id.json');
    final bytes = await file.readAsBytes();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

void main() {
  late CitySearchLocalDataSourceImpl dataSource;

  setUp(() => dataSource = CitySearchLocalDataSourceImpl(_RealAssetBundle()));

  test('loads the bundled dataset', () async {
    final cities = await dataSource.all();
    expect(cities.length, greaterThanOrEqualTo(50));
  });

  test('every city carries coordinates inside Indonesia', () async {
    for (final city in await dataSource.all()) {
      expect(
        city.latitude,
        inInclusiveRange(-11.5, 6.5),
        reason: '${city.name} latitude out of range',
      );
      expect(
        city.longitude,
        inInclusiveRange(94.5, 141.5),
        reason: '${city.name} longitude out of range',
      );
    }
  });

  test('every city carries one of the three Indonesian zones', () async {
    const zones = {'Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura'};
    for (final city in await dataSource.all()) {
      expect(zones, contains(city.timeZoneId), reason: city.name);
    }
  });

  test('zone matches longitude — WIB west, WITA centre, WIT east', () async {
    // A city filed under the wrong zone shifts its whole schedule by an
    // hour, which is the single worst failure this dataset can cause.
    for (final city in await dataSource.all()) {
      final expected = switch (city.timeZoneId) {
        'Asia/Jakarta' => const [94.0, 116.0],
        'Asia/Makassar' => const [114.0, 136.0],
        _ => const [124.0, 142.0],
      };
      expect(
        city.longitude,
        inInclusiveRange(expected[0], expected[1]),
        reason: '${city.name} (${city.timeZoneId}) sits at ${city.longitude}',
      );
    }
  });

  test('search matches on city name, case-insensitively', () async {
    final results = await dataSource.search('bandung');
    expect(results.map((c) => c.name), contains('Bandung'));
  });

  test('search matches on province too', () async {
    final results = await dataSource.search('Papua');
    expect(results, isNotEmpty);
  });

  test(
    'an empty query returns everything, so the picker is never blank',
    () async {
      final all = await dataSource.all();
      expect((await dataSource.search('   ')).length, all.length);
    },
  );

  test('an unmatched query returns empty rather than throwing', () async {
    expect(await dataSource.search('Reykjavik'), isEmpty);
  });

  test('the asset is valid, compact JSON', () async {
    final raw = await File('assets/data/cities_id.json').readAsString();
    expect(jsonDecode(raw), isA<List<dynamic>>());
    // Compact encoding keeps the APK small; a pretty-printed file would be
    // several times the size for no benefit.
    expect(raw.contains('\n'), isFalse);
  });
}
