import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/utils/countdown_format.dart';

void main() {
  group('formatCountdown', () {
    test('drops the hour part below an hour', () {
      expect(formatCountdown(const Duration(minutes: 39, seconds: 7)), '39:07');
      expect(formatCountdown(const Duration(minutes: 9, seconds: 7)), '9:07');
      expect(formatCountdown(const Duration(minutes: 59, seconds: 7)), '59:07');
    });

    test('shows hours with zero-padded minutes', () {
      expect(formatCountdown(const Duration(hours: 1)), '1:00:00');
      expect(
        formatCountdown(const Duration(hours: 5, minutes: 12, seconds: 44)),
        '5:12:44',
      );
      expect(
        formatCountdown(const Duration(hours: 8, minutes: 2, seconds: 5)),
        '8:02:05',
      );
    });

    test('a sub-second remainder is not yet zero', () {
      // The whole point of the change. Flooring would print 0:00 while the
      // prayer time has not arrived — the same lie the old minute-resolution
      // countdown told, which is what the user reported as "0 menit".
      expect(formatCountdown(const Duration(milliseconds: 300)), '0:01');
      expect(formatCountdown(const Duration(milliseconds: 999)), '0:01');
      expect(formatCountdown(const Duration(seconds: 59)), '0:59');
    });

    test('bottoms out at zero', () {
      expect(formatCountdown(Duration.zero), '0:00');
      expect(formatCountdown(const Duration(seconds: -5)), '0:00');
    });
  });

  group('countdownSeconds', () {
    test('rounds up and never goes negative', () {
      expect(countdownSeconds(const Duration(milliseconds: 1)), 1);
      expect(countdownSeconds(const Duration(seconds: 59)), 59);
      expect(countdownSeconds(Duration.zero), 0);
      expect(countdownSeconds(const Duration(hours: -1)), 0);
    });
  });
}
