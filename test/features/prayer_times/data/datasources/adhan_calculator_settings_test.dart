import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/config/calculation_presets.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/features/prayer_times/data/datasources/adhan_calculator_data_source.dart';
import 'package:tanbih/features/prayer_times/domain/entities/calculation_settings.dart';
import 'package:tanbih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:tanbih/features/prayer_times/domain/entities/hijri_date.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Each user-facing calculation option gets its own test, because a setting
/// that silently does nothing is indistinguishable from a working one in the
/// UI — the number just looks plausible.
void main() {
  setUpAll(tz_data.initializeTimeZones);

  const calculator = AdhanCalculatorDataSourceImpl();

  // Monday, so Jumu'ah is inactive unless a test picks a Friday.
  final monday = DateTime(2026, 9, 7);
  final friday = DateTime(2026, 9, 11);

  const ramadan = HijriDate(
    year: 1448,
    month: 9,
    day: 15,
    monthName: 'Ramadhan',
  );
  const notRamadan = HijriDate(
    year: 1448,
    month: 3,
    day: 1,
    monthName: "Rabi'ul Awal",
  );

  DailyPrayerTimes compute({
    required CalculationSettings settings,
    DateTime? date,
    HijriDate hijri = notRamadan,
  }) => calculator.calculate(
    latitude: -6.2088,
    longitude: 106.8456,
    date: date ?? monday,
    timeZoneId: 'Asia/Jakarta',
    settings: settings,
    hijriDate: hijri,
  );

  int minutesBetween(DailyPrayerTimes a, DailyPrayerTimes b, PrayerSlot slot) =>
      b.entryFor(slot)!.time.difference(a.entryFor(slot)!.time).inMinutes;

  group('juristic method', () {
    test('hanafi pushes Asr later than shafi', () {
      final shafi = compute(
        settings: const CalculationSettings(madhab: MadhabId.shafi),
      );
      final hanafi = compute(
        settings: const CalculationSettings(madhab: MadhabId.hanafi),
      );

      expect(minutesBetween(shafi, hanafi, PrayerSlot.asr), greaterThan(30));
    });

    test('madhab leaves the other prayers untouched', () {
      final shafi = compute(
        settings: const CalculationSettings(madhab: MadhabId.shafi),
      );
      final hanafi = compute(
        settings: const CalculationSettings(madhab: MadhabId.hanafi),
      );

      for (final slot in [
        PrayerSlot.fajr,
        PrayerSlot.dhuhr,
        PrayerSlot.maghrib,
        PrayerSlot.isha,
      ]) {
        expect(minutesBetween(shafi, hanafi, slot), 0);
      }
    });
  });

  group('Ramadan Isha adjustment', () {
    test('adds 30 minutes during Ramadan under Umm al-Qura', () {
      const base = CalculationSettings(method: CalculationMethodId.ummAlQura);
      const adjusted = CalculationSettings(
        method: CalculationMethodId.ummAlQura,
        adjustIshaInRamadan: true,
      );

      final without = compute(settings: base, hijri: ramadan);
      final with30 = compute(settings: adjusted, hijri: ramadan);

      expect(minutesBetween(without, with30, PrayerSlot.isha), 30);
    });

    test('does nothing outside Ramadan', () {
      const adjusted = CalculationSettings(
        method: CalculationMethodId.ummAlQura,
        adjustIshaInRamadan: true,
      );
      final base = compute(
        settings: const CalculationSettings(
          method: CalculationMethodId.ummAlQura,
        ),
        hijri: notRamadan,
      );
      final applied = compute(settings: adjusted, hijri: notRamadan);

      expect(minutesBetween(base, applied, PrayerSlot.isha), 0);
    });

    test('does nothing for methods that do not define it', () {
      // The switch is hidden in the UI for other methods, but a stale `true`
      // left over from a method change must not silently shift Isha.
      const kemenagWithFlag = CalculationSettings(adjustIshaInRamadan: true);
      final base = compute(
        settings: const CalculationSettings(),
        hijri: ramadan,
      );
      final flagged = compute(settings: kemenagWithFlag, hijri: ramadan);

      expect(minutesBetween(base, flagged, PrayerSlot.isha), 0);
      expect(kemenagWithFlag.ramadanIshaAdjustmentActive, isFalse);
    });
  });

  group('daylight saving adjustment', () {
    test('shifts every astronomical time by one hour', () {
      final base = compute(settings: const CalculationSettings());
      final dst = compute(
        settings: const CalculationSettings(adjustDaylightSaving: true),
      );

      for (final slot in [
        PrayerSlot.imsak,
        PrayerSlot.fajr,
        PrayerSlot.sunrise,
        PrayerSlot.dhuhr,
        PrayerSlot.asr,
        PrayerSlot.maghrib,
        PrayerSlot.isha,
      ]) {
        expect(
          minutesBetween(base, dst, slot),
          60,
          reason: '${slot.name} should move a full hour',
        );
      }
    });
  });

  group("Jumu'ah", () {
    test('replaces Dhuhr on Friday when a time is set', () {
      final times = compute(
        date: friday,
        settings: const CalculationSettings(jumuahHour: 12, jumuahMinute: 15),
      );

      expect(times.entryFor(PrayerSlot.jumuah), isNotNull);
      expect(times.entryFor(PrayerSlot.dhuhr), isNull);

      final jumuah = times.entryFor(PrayerSlot.jumuah)!.time;
      expect(jumuah.hour, 12);
      expect(jumuah.minute, 15);
    });

    test('is ignored on other days', () {
      final times = compute(
        date: monday,
        settings: const CalculationSettings(jumuahHour: 12, jumuahMinute: 15),
      );

      expect(times.entryFor(PrayerSlot.jumuah), isNull);
      expect(times.entryFor(PrayerSlot.dhuhr), isNotNull);
    });

    test('is ignored on Friday when no time is set', () {
      final times = compute(
        date: friday,
        settings: const CalculationSettings(),
      );

      expect(times.entryFor(PrayerSlot.jumuah), isNull);
      expect(times.entryFor(PrayerSlot.dhuhr), isNotNull);
    });

    test('counts as a prayer for scheduling purposes', () {
      final times = compute(
        date: friday,
        settings: const CalculationSettings(jumuahHour: 12, jumuahMinute: 15),
      );

      expect(
        times.prayerEntries.map((e) => e.slot),
        contains(PrayerSlot.jumuah),
      );
      // Five prayers, with Jumu'ah standing in for Dhuhr.
      expect(times.prayerEntries.length, 5);
    });
  });

  group('manual adjustments', () {
    test('stack on top of the method ihtiyati', () {
      final base = compute(settings: const CalculationSettings());
      final shifted = compute(
        settings: const CalculationSettings(
          manualAdjustments: {PrayerSlot.maghrib: 3, PrayerSlot.fajr: -4},
        ),
      );

      expect(minutesBetween(base, shifted, PrayerSlot.maghrib), 3);
      expect(minutesBetween(base, shifted, PrayerSlot.fajr), -4);
      expect(minutesBetween(base, shifted, PrayerSlot.asr), 0);
    });

    test('a Fajr adjustment carries into the derived imsak', () {
      final base = compute(settings: const CalculationSettings());
      final shifted = compute(
        settings: const CalculationSettings(
          manualAdjustments: {PrayerSlot.fajr: 5},
        ),
      );

      expect(minutesBetween(base, shifted, PrayerSlot.imsak), 5);
    });
  });

  group('imsak offset', () {
    test('defaults to 10 minutes before Fajr', () {
      final times = compute(settings: const CalculationSettings());
      final fajr = times.entryFor(PrayerSlot.fajr)!.time;
      final imsak = times.entryFor(PrayerSlot.imsak)!.time;

      expect(fajr.difference(imsak).inMinutes, 10);
    });

    test('honours a custom offset', () {
      final times = compute(
        settings: const CalculationSettings(imsakOffsetMinutes: 15),
      );
      final fajr = times.entryFor(PrayerSlot.fajr)!.time;
      final imsak = times.entryFor(PrayerSlot.imsak)!.time;

      expect(fajr.difference(imsak).inMinutes, 15);
    });

    test('an imsak adjustment moves imsak without moving Fajr', () {
      final base = compute(settings: const CalculationSettings());
      final shifted = compute(
        settings: const CalculationSettings(
          manualAdjustments: {PrayerSlot.imsak: 2},
        ),
      );

      expect(minutesBetween(base, shifted, PrayerSlot.imsak), 2);
      expect(minutesBetween(base, shifted, PrayerSlot.fajr), 0);
    });
  });

  group('invalid input', () {
    test('rejects out-of-range coordinates', () {
      expect(
        () => calculator.calculate(
          latitude: 95,
          longitude: 106.8456,
          date: monday,
          timeZoneId: 'Asia/Jakarta',
          settings: const CalculationSettings(),
          hijriDate: notRamadan,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('rejects an unknown time zone', () {
      expect(
        () => calculator.calculate(
          latitude: -6.2088,
          longitude: 106.8456,
          date: monday,
          timeZoneId: 'Mars/Olympus',
          settings: const CalculationSettings(),
          hijriDate: notRamadan,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('qibla', () {
    test('from Jakarta the bearing points west-north-west', () {
      final bearing = calculator.qiblaDirection(
        latitude: -6.2088,
        longitude: 106.8456,
      );
      // Widely published value for Jakarta is ~295 degrees from true north.
      expect(bearing, closeTo(295, 1.5));
    });
  });
}
