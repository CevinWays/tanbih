// Scratch calibration against the Kemenag reference timetable.
// Compares WALL CLOCK in Asia/Jakarta, not instants.
// Run with: dart run tool/kemenag_check.dart
// ignore_for_file: avoid_print — these are CLI calibration scripts,
// not part of the shipped app.
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/features/prayer_times/data/datasources/adhan_calculator_data_source.dart';
import 'package:tanbih/features/prayer_times/domain/entities/calculation_settings.dart';
import 'package:tanbih/features/prayer_times/domain/entities/hijri_date.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

const slots = [
  PrayerSlot.imsak,
  PrayerSlot.fajr,
  PrayerSlot.sunrise,
  PrayerSlot.dhuhr,
  PrayerSlot.asr,
  PrayerSlot.maghrib,
  PrayerSlot.isha,
];

void main() {
  tz_data.initializeTimeZones();
  const calc = AdhanCalculatorDataSourceImpl();

  final reference = <String, Map<String, String>>{
    '2026-09-07': {
      'imsak': '04:25',
      'fajr': '04:35',
      'sunrise': '05:47',
      'dhuhr': '11:54',
      'asr': '15:10',
      'maghrib': '17:55',
      'isha': '19:03',
    },
    '2026-06-21': {
      'imsak': '04:30',
      'fajr': '04:40',
      'sunrise': '05:58',
      'dhuhr': '11:58',
      'asr': '15:19',
      'maghrib': '17:51',
      'isha': '19:05',
    },
    '2026-12-21': {
      'imsak': '04:03',
      'fajr': '04:13',
      'sunrise': '05:33',
      'dhuhr': '11:54',
      'asr': '15:20',
      'maghrib': '18:08',
      'isha': '19:24',
    },
    '2027-03-20': {
      'imsak': '04:32',
      'fajr': '04:42',
      'sunrise': '05:54',
      'dhuhr': '12:04',
      'asr': '15:13',
      'maghrib': '18:07',
      'isha': '19:15',
    },
  };

  final candidates = <String, List<double>>{
    'monas   ': [-6.1751, 106.8650],
    'central ': [-6.2088, 106.8456],
    'kemenag ': [-6.1944, 106.8229],
    'south   ': [-6.2615, 106.8106],
    'north   ': [-6.1214, 106.8745],
  };

  for (final entry in candidates.entries) {
    final lat = entry.value[0];
    final lng = entry.value[1];
    final perSlot = {for (final s in slots) s: <int>[]};

    for (final ref in reference.entries) {
      final parts = ref.key.split('-').map(int.parse).toList();
      final date = DateTime(parts[0], parts[1], parts[2]);
      final times = calc.calculate(
        latitude: lat,
        longitude: lng,
        date: date,
        timeZoneId: 'Asia/Jakarta',
        settings: const CalculationSettings(),
        hijriDate: const HijriDate(
          year: 1448,
          month: 3,
          day: 1,
          monthName: 'x',
        ),
      );

      for (final slot in slots) {
        final got = times.entryFor(slot)!.time;
        final want = ref.value[slot.name]!.split(':').map(int.parse).toList();
        // Wall-clock minutes-of-day difference.
        final delta = (got.hour * 60 + got.minute) - (want[0] * 60 + want[1]);
        perSlot[slot]!.add(delta);
      }
    }

    final summary = slots
        .map((s) {
          final ds = perSlot[s]!;
          final mean = ds.reduce((a, b) => a + b) / ds.length;
          final worst = ds.map((d) => d.abs()).reduce((a, b) => a > b ? a : b);
          return '${s.name.substring(0, 3)} mean=${mean.toStringAsFixed(2)} '
              'worst=$worst ${ds.toString()}';
        })
        .join('\n    ');
    print('${entry.key} ($lat, $lng)\n    $summary');
  }
}
