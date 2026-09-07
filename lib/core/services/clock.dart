import 'package:injectable/injectable.dart';

/// Injectable source of "now".
///
/// Tanbih is a time-driven app: prayer schedules, countdowns, and alarm
/// windows are all derived from the current instant. Calling
/// `DateTime.now()` directly would make those paths untestable, so domain,
/// data, and bloc code must depend on this instead. See CLAUDE.md § Waktu.
abstract class Clock {
  DateTime now();

  /// Midnight of the current day in local time — the anchor for a day's
  /// prayer schedule.
  DateTime today();
}

@LazySingleton(as: Clock)
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }
}

/// Test double. Advance it explicitly rather than sleeping.
class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  void setNow(DateTime value) => _now = value;

  void advance(Duration by) => _now = _now.add(by);

  @override
  DateTime now() => _now;

  @override
  DateTime today() => DateTime(_now.year, _now.month, _now.day);
}
