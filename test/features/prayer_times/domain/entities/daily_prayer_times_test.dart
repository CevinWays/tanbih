import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:tanbih/features/prayer_times/domain/entities/hijri_date.dart';
import 'package:tanbih/features/prayer_times/domain/entities/prayer_time_entry.dart';

void main() {
  const hijri = HijriDate(
    year: 1448,
    month: 3,
    day: 1,
    monthName: "Rabi'ul Awal",
  );

  final day = DateTime(2026, 9, 7);

  PrayerTimeEntry at(PrayerSlot slot, int hour, int minute) => PrayerTimeEntry(
    slot: slot,
    time: DateTime(day.year, day.month, day.day, hour, minute),
  );

  final schedule = DailyPrayerTimes(
    date: day,
    hijriDate: hijri,
    entries: [
      at(PrayerSlot.imsak, 4, 25),
      at(PrayerSlot.fajr, 4, 35),
      at(PrayerSlot.sunrise, 5, 47),
      at(PrayerSlot.dhuhr, 11, 54),
      at(PrayerSlot.asr, 15, 10),
      at(PrayerSlot.maghrib, 17, 55),
      at(PrayerSlot.isha, 19, 3),
    ],
  );

  group('prayerEntries', () {
    test('excludes the informational imsak and sunrise rows', () {
      expect(schedule.prayerEntries.map((e) => e.slot), [
        PrayerSlot.fajr,
        PrayerSlot.dhuhr,
        PrayerSlot.asr,
        PrayerSlot.maghrib,
        PrayerSlot.isha,
      ]);
    });
  });

  group('nextPrayerAt', () {
    test('before Fajr the next prayer is Fajr', () {
      final next = schedule.nextPrayerAt(DateTime(2026, 9, 7, 3));
      expect(next!.slot, PrayerSlot.fajr);
    });

    test('between Dhuhr and Asr the next prayer is Asr', () {
      final next = schedule.nextPrayerAt(DateTime(2026, 9, 7, 13));
      expect(next!.slot, PrayerSlot.asr);
    });

    test('sunrise is never returned as the next prayer', () {
      // 05:00 sits between Fajr and sunrise; the answer must skip past
      // sunrise to Dhuhr rather than counting down to a non-prayer.
      final next = schedule.nextPrayerAt(DateTime(2026, 9, 7, 5));
      expect(next!.slot, PrayerSlot.dhuhr);
    });

    test('after Isha there is nothing left today', () {
      expect(schedule.nextPrayerAt(DateTime(2026, 9, 7, 23, 59)), isNull);
      expect(schedule.timeUntilNext(DateTime(2026, 9, 7, 23, 59)), isNull);
    });

    test('exactly at a prayer time that prayer is current, not next', () {
      final at1554 = DateTime(2026, 9, 7, 15, 10);
      expect(schedule.currentPrayerAt(at1554)!.slot, PrayerSlot.asr);
      expect(schedule.nextPrayerAt(at1554)!.slot, PrayerSlot.maghrib);
    });
  });

  group('currentPrayerAt', () {
    test('is null before Fajr — the current prayer belongs to yesterday', () {
      expect(schedule.currentPrayerAt(DateTime(2026, 9, 7, 2)), isNull);
    });

    test('after Isha the current prayer stays Isha', () {
      expect(
        schedule.currentPrayerAt(DateTime(2026, 9, 7, 22))!.slot,
        PrayerSlot.isha,
      );
    });

    test('during the Fajr window the current prayer is Fajr', () {
      expect(
        schedule.currentPrayerAt(DateTime(2026, 9, 7, 5, 30))!.slot,
        PrayerSlot.fajr,
      );
    });
  });

  group('timeUntilNext', () {
    test('measures to the next prayer, not the next row', () {
      final remaining = schedule.timeUntilNext(DateTime(2026, 9, 7, 11, 24));
      expect(remaining, const Duration(minutes: 30));
    });
  });

  group('entryFor', () {
    test('returns null for a slot the day does not contain', () {
      expect(schedule.entryFor(PrayerSlot.jumuah), isNull);
      expect(schedule.entryFor(PrayerSlot.asr), isNotNull);
    });
  });
}
