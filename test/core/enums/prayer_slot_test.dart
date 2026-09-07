import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';

void main() {
  group('PrayerSlot', () {
    test('imsak and sunrise are informational, not prayers', () {
      expect(PrayerSlot.imsak.isPrayer, isFalse);
      expect(PrayerSlot.sunrise.isPrayer, isFalse);
    });

    test('the five obligatory prayers plus jumuah are prayers', () {
      const prayers = [
        PrayerSlot.fajr,
        PrayerSlot.dhuhr,
        PrayerSlot.jumuah,
        PrayerSlot.asr,
        PrayerSlot.maghrib,
        PrayerSlot.isha,
      ];
      for (final slot in prayers) {
        expect(
          slot.isPrayer,
          isTrue,
          reason: '${slot.name} should be a prayer',
        );
        expect(slot.canPlayAdhan, isTrue);
      }
    });

    test('declaration order is chronological', () {
      expect(PrayerSlot.values, [
        PrayerSlot.imsak,
        PrayerSlot.fajr,
        PrayerSlot.sunrise,
        PrayerSlot.dhuhr,
        PrayerSlot.jumuah,
        PrayerSlot.asr,
        PrayerSlot.maghrib,
        PrayerSlot.isha,
      ]);
    });

    test('slotIndex stays stable — notification ids depend on it', () {
      // Reordering the enum would silently repoint every pending
      // notification id at a different prayer.
      expect(PrayerSlot.imsak.slotIndex, 0);
      expect(PrayerSlot.fajr.slotIndex, 1);
      expect(PrayerSlot.sunrise.slotIndex, 2);
      expect(PrayerSlot.dhuhr.slotIndex, 3);
      expect(PrayerSlot.jumuah.slotIndex, 4);
      expect(PrayerSlot.asr.slotIndex, 5);
      expect(PrayerSlot.maghrib.slotIndex, 6);
      expect(PrayerSlot.isha.slotIndex, 7);
    });

    test('slot count fits the 20-slot stride used for notification ids', () {
      expect(PrayerSlot.values.length, lessThan(10));
    });
  });
}
