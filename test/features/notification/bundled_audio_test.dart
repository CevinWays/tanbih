import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the shipped audio itself.
///
/// A channel whose sound resource is missing fails silently — the
/// notification arrives with no sound and nothing in the logs explains it —
/// so the files' presence and shape are asserted here rather than trusted.
void main() {
  test('the notification clip is bundled where Android expects it', () {
    // Channel sounds must be a res/raw resource; a Flutter asset cannot be
    // used for this.
    final clip = File('android/app/src/main/res/raw/adhan_short.ogg');
    expect(clip.existsSync(), isTrue);
    expect(clip.lengthSync(), greaterThan(10 * 1024));
  });

  test('the full adhan is bundled as a Flutter asset', () {
    final full = File('assets/audio/adhan_full.ogg');
    expect(full.existsSync(), isTrue);
    expect(full.lengthSync(), greaterThan(100 * 1024));
  });

  test('the clip stays under the 30 second ceiling iOS enforces', () {
    // Ogg pages carry a granule position; the last one gives the sample
    // count, which at 44.1 kHz gives the duration without a decoder.
    final bytes = File(
      'android/app/src/main/res/raw/adhan_short.ogg',
    ).readAsBytesSync();

    var lastGranule = 0;
    for (var i = bytes.length - 1; i >= 3; i--) {
      if (bytes[i - 3] == 0x4F &&
          bytes[i - 2] == 0x67 &&
          bytes[i - 1] == 0x67 &&
          bytes[i] == 0x53) {
        var granule = 0;
        for (var b = 7; b >= 0; b--) {
          granule = (granule << 8) | bytes[i + 3 + b];
        }
        lastGranule = granule;
        break;
      }
    }

    final seconds = lastGranule / 44100;
    expect(seconds, greaterThan(25));
    expect(seconds, lessThanOrEqualTo(30));
  });

  test('the audio credits record the source and licence', () {
    // The rule is that nothing ships without its provenance written down.
    final credits = File('assets/audio/CREDITS.md').readAsStringSync();
    expect(credits, contains('CC0'));
    expect(credits, contains('commons.wikimedia.org'));
    expect(credits, contains('adhan_full.ogg'));
    expect(credits, contains('adhan_short.ogg'));
  });
}
