// Scratch calibration check across Indonesian time zones.
// Run with: dart run tool/kemenag_multicity_check.dart
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

class City {
  const City(this.name, this.lat, this.lng, this.zone, this.reference);
  final String name;
  final double lat;
  final double lng;
  final String zone;
  final Map<String, List<String>> reference;
}

void main() {
  tz_data.initializeTimeZones();
  const calc = AdhanCalculatorDataSourceImpl();

  const cities = [
    City('Jakarta  (WIB)', -6.2088, 106.8456, 'Asia/Jakarta', {
      '2026-09-07': [
        '04:25',
        '04:35',
        '05:47',
        '11:54',
        '15:10',
        '17:55',
        '19:03',
      ],
      '2026-12-21': [
        '04:03',
        '04:13',
        '05:33',
        '11:54',
        '15:20',
        '18:08',
        '19:24',
      ],
    }),
    City('Makassar (WITA)', -5.1477, 119.4327, 'Asia/Makassar', {
      '2026-09-07': [
        '04:35',
        '04:45',
        '05:56',
        '12:04',
        '15:19',
        '18:05',
        '19:13',
      ],
      '2026-12-21': [
        '04:15',
        '04:25',
        '05:44',
        '12:04',
        '15:30',
        '18:16',
        '19:31',
      ],
    }),
    City('Jayapura (WIT)', -2.5916, 140.6690, 'Asia/Jayapura', {
      '2026-09-07': [
        '04:09',
        '04:19',
        '05:30',
        '11:39',
        '14:51',
        '17:41',
        '18:49',
      ],
      '2026-12-21': [
        '03:55',
        '04:05',
        '05:24',
        '11:39',
        '15:04',
        '17:46',
        '19:01',
      ],
    }),
  ];

  var globalWorst = 0;

  for (final city in cities) {
    final lines = <String>[];
    var worst = 0;

    for (final ref in city.reference.entries) {
      final parts = ref.key.split('-').map(int.parse).toList();
      final date = DateTime(parts[0], parts[1], parts[2]);
      final times = calc.calculate(
        latitude: city.lat,
        longitude: city.lng,
        date: date,
        timeZoneId: city.zone,
        settings: const CalculationSettings(),
        hijriDate: const HijriDate(
          year: 1448,
          month: 3,
          day: 1,
          monthName: 'x',
        ),
      );

      final deltas = <int>[];
      for (var i = 0; i < slots.length; i++) {
        final got = times.entryFor(slots[i])!.time;
        final want = ref.value[i].split(':').map(int.parse).toList();
        final delta = (got.hour * 60 + got.minute) - (want[0] * 60 + want[1]);
        deltas.add(delta);
        if (delta.abs() > worst) worst = delta.abs();
      }
      lines.add('    ${ref.key}  $deltas');
    }

    if (worst > globalWorst) globalWorst = worst;
    print('${city.name}  worst=${worst}m');
    lines.forEach(print);
  }

  print(
    '\nGLOBAL WORST: ${globalWorst}m '
    '(order: imsak fajr sunrise dhuhr asr maghrib isha)',
  );
}
