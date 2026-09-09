import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/config/calculation_presets.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/features/prayer_times/data/datasources/adhan_calculator_data_source.dart';
import 'package:tanbih/features/prayer_times/domain/entities/calculation_settings.dart';
import 'package:tanbih/features/prayer_times/domain/entities/hijri_date.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Accuracy contract for the prayer engine.
///
/// Reference values come from the Kemenag RI timetable (via
/// api.myquran.com, which republishes it) for three cities spanning all
/// three Indonesian time zones, on dates near both solstices.
///
/// **This is the app's most important test.** A change to
/// `AdhanCalculatorDataSource` or to `KemenagIhtiyati` that breaks it is a
/// change that makes users pray at the wrong time — do not relax the
/// tolerance to make it pass.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  const calculator = AdhanCalculatorDataSourceImpl();

  /// Maximum acceptable deviation from the official timetable.
  const toleranceMinutes = 1;

  const slotOrder = [
    PrayerSlot.imsak,
    PrayerSlot.fajr,
    PrayerSlot.sunrise,
    PrayerSlot.dhuhr,
    PrayerSlot.asr,
    PrayerSlot.maghrib,
    PrayerSlot.isha,
  ];

  /// Values as published: imsak, fajr, sunrise, dhuhr, asr, maghrib, isha.
  const cases = <_GoldenCase>[
    _GoldenCase(
      city: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      timeZoneId: 'Asia/Jakarta',
      date: '2026-09-07',
      expected: ['04:25', '04:35', '05:47', '11:54', '15:10', '17:55', '19:03'],
    ),
    _GoldenCase(
      city: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      timeZoneId: 'Asia/Jakarta',
      date: '2026-06-21',
      expected: ['04:30', '04:40', '05:58', '11:58', '15:19', '17:51', '19:05'],
    ),
    _GoldenCase(
      city: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      timeZoneId: 'Asia/Jakarta',
      date: '2026-12-21',
      expected: ['04:03', '04:13', '05:33', '11:54', '15:20', '18:08', '19:24'],
    ),
    _GoldenCase(
      city: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      timeZoneId: 'Asia/Jakarta',
      date: '2027-03-20',
      expected: ['04:32', '04:42', '05:54', '12:04', '15:13', '18:07', '19:15'],
    ),
    _GoldenCase(
      city: 'Makassar',
      latitude: -5.1477,
      longitude: 119.4327,
      timeZoneId: 'Asia/Makassar',
      date: '2026-09-07',
      expected: ['04:35', '04:45', '05:56', '12:04', '15:19', '18:05', '19:13'],
    ),
    _GoldenCase(
      city: 'Makassar',
      latitude: -5.1477,
      longitude: 119.4327,
      timeZoneId: 'Asia/Makassar',
      date: '2026-12-21',
      expected: ['04:15', '04:25', '05:44', '12:04', '15:30', '18:16', '19:31'],
    ),
    _GoldenCase(
      city: 'Jayapura',
      latitude: -2.5916,
      longitude: 140.6690,
      timeZoneId: 'Asia/Jayapura',
      date: '2026-09-07',
      expected: ['04:09', '04:19', '05:30', '11:39', '14:51', '17:41', '18:49'],
    ),
    _GoldenCase(
      city: 'Jayapura',
      latitude: -2.5916,
      longitude: 140.6690,
      timeZoneId: 'Asia/Jayapura',
      date: '2026-12-21',
      expected: ['03:55', '04:05', '05:24', '11:39', '15:04', '17:46', '19:01'],
    ),
  ];

  group('Kemenag timetable, default settings', () {
    for (final c in cases) {
      test('${c.city} ${c.date} is within $toleranceMinutes minute(s)', () {
        final date = c.parsedDate;
        final times = calculator.calculate(
          latitude: c.latitude,
          longitude: c.longitude,
          date: date,
          timeZoneId: c.timeZoneId,
          settings: const CalculationSettings(),
          hijriDate: _nonRamadan,
        );

        for (var i = 0; i < slotOrder.length; i++) {
          final slot = slotOrder[i];
          final actual = times.entryFor(slot)!.time;
          final expected = c.expectedMinutesOfDay(i);
          final actualMinutes = actual.hour * 60 + actual.minute;

          expect(
            (actualMinutes - expected).abs(),
            lessThanOrEqualTo(toleranceMinutes),
            reason:
                '${c.city} ${c.date} ${slot.name}: '
                'expected ${c.expected[i]}, got '
                '${actual.hour.toString().padLeft(2, '0')}:'
                '${actual.minute.toString().padLeft(2, '0')}',
          );
        }
      });
    }

    test('times are anchored in the location zone, not the device zone', () {
      // Jakarta is UTC+7. Whatever the machine running the suite is set to,
      // Dhuhr must read ~11:54 local and the instant must be 04:54Z.
      final times = calculator.calculate(
        latitude: -6.2088,
        longitude: 106.8456,
        date: DateTime(2026, 9, 7),
        timeZoneId: 'Asia/Jakarta',
        settings: const CalculationSettings(),
        hijriDate: _nonRamadan,
      );

      final dhuhr = times.entryFor(PrayerSlot.dhuhr)!.time;
      expect(dhuhr.timeZoneOffset, const Duration(hours: 7));
      expect(dhuhr.hour, 11);
      expect(dhuhr.toUtc().hour, 4);
    });

    test('entries are chronologically ordered', () {
      final times = calculator.calculate(
        latitude: -6.2088,
        longitude: 106.8456,
        date: DateTime(2026, 9, 7),
        timeZoneId: 'Asia/Jakarta',
        settings: const CalculationSettings(),
        hijriDate: _nonRamadan,
      );

      for (var i = 1; i < times.entries.length; i++) {
        expect(
          times.entries[i].time.isAfter(times.entries[i - 1].time),
          isTrue,
          reason:
              '${times.entries[i].slot.name} must come after '
              '${times.entries[i - 1].slot.name}',
        );
      }
    });

    test('Kemenag uses Fajr 20 and Isha 18 degrees', () {
      final params = CalculationPresets.parametersFor(
        CalculationMethodId.kemenag,
      );
      expect(params.fajrAngle, 20.0);
      expect(params.ishaAngle, 18.0);
    });
  });
}

const _nonRamadan = HijriDate(
  year: 1448,
  month: 3,
  day: 1,
  monthName: "Rabi'ul Awal",
);

class _GoldenCase {
  const _GoldenCase({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
    required this.date,
    required this.expected,
  });

  final String city;
  final double latitude;
  final double longitude;
  final String timeZoneId;
  final String date;
  final List<String> expected;

  DateTime get parsedDate {
    final parts = date.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  int expectedMinutesOfDay(int index) {
    final parts = expected[index].split(':').map(int.parse).toList();
    return parts[0] * 60 + parts[1];
  }
}
