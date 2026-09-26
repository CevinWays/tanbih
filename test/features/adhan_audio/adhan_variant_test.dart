import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/features/adhan_audio/domain/adhan_variant.dart';

/// The Fajr adhan carries the tathwib — "as-salatu khayrun min an-nawm" —
/// which no other prayer's does. These pin the routing so that the day a
/// proper Fajr recording exists, only the asset path has to change.
void main() {
  test('Fajr takes its own variant, every other prayer the standard one', () {
    expect(AdhanVariant.forSlot(PrayerSlot.fajr), AdhanVariant.fajr);

    for (final slot in [
      PrayerSlot.dhuhr,
      PrayerSlot.jumuah,
      PrayerSlot.asr,
      PrayerSlot.maghrib,
      PrayerSlot.isha,
    ]) {
      expect(
        AdhanVariant.forSlot(slot),
        AdhanVariant.standard,
        reason: '${slot.name} should use the ordinary adhan',
      );
    }
  });

  test('every variant points at an asset that is actually bundled', () {
    // A missing asset fails silently: the service starts, MediaPlayer cannot
    // open the file, and the adhan simply never sounds.
    for (final variant in AdhanVariant.values) {
      expect(
        File(variant.fullAsset).existsSync(),
        isTrue,
        reason: '${variant.name} points at ${variant.fullAsset}',
      );
    }
  });

  test('the Fajr fallback is declared, not accidental', () {
    // Until a tathwib recording can be licensed, Fajr plays the ordinary
    // adhan. That is a known gap, and the flag exists so the UI can say so
    // rather than implying a distinction the audio does not make. When the
    // recording lands, this expectation flips and the test is the reminder.
    expect(AdhanVariant.fajr.usesFallbackRecording, isTrue);
    expect(AdhanVariant.standard.usesFallbackRecording, isFalse);
  });

  test('the asset path is declared the way Flutter packs it', () {
    for (final variant in AdhanVariant.values) {
      expect(variant.fullAsset, startsWith('assets/audio/'));
      expect(variant.fullAsset, endsWith('.ogg'));
    }
  });
}
