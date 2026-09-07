import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/services/clock.dart';

void main() {
  group('SystemClock', () {
    test('today() strips the time component', () {
      const clock = SystemClock();
      final today = clock.today();
      expect(today.hour, 0);
      expect(today.minute, 0);
      expect(today.second, 0);
      expect(today.millisecond, 0);
    });
  });

  group('FakeClock', () {
    test('returns the instant it was given', () {
      final clock = FakeClock(DateTime(2026, 9, 7, 17, 30));
      expect(clock.now(), DateTime(2026, 9, 7, 17, 30));
      expect(clock.today(), DateTime(2026, 9, 7));
    });

    test('advance moves time forward', () {
      final clock = FakeClock(DateTime(2026, 9, 7, 23, 30));
      clock.advance(const Duration(hours: 1));
      expect(clock.now(), DateTime(2026, 9, 8, 0, 30));
      expect(clock.today(), DateTime(2026, 9, 8));
    });

    test('setNow replaces the instant', () {
      final clock = FakeClock(DateTime(2026, 1, 1));
      clock.setNow(DateTime(2026, 3, 20, 5, 15));
      expect(clock.now(), DateTime(2026, 3, 20, 5, 15));
    });
  });
}
