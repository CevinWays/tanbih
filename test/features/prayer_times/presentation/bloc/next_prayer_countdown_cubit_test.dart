import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/core/services/clock.dart';
import 'package:tanbih/core/utils/countdown_format.dart';
import 'package:tanbih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:tanbih/features/prayer_times/domain/entities/hijri_date.dart';
import 'package:tanbih/features/prayer_times/domain/entities/prayer_time_entry.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/next_prayer_countdown_cubit.dart';

void main() {
  const hijri = HijriDate(
    year: 1448,
    month: 3,
    day: 1,
    monthName: "Rabi'ul Awal",
  );

  DailyPrayerTimes scheduleFor(DateTime day) => DailyPrayerTimes(
    date: DateTime(day.year, day.month, day.day),
    hijriDate: hijri,
    entries: [
      PrayerTimeEntry(
        slot: PrayerSlot.fajr,
        time: DateTime(day.year, day.month, day.day, 4, 35),
      ),
      PrayerTimeEntry(
        slot: PrayerSlot.dhuhr,
        time: DateTime(day.year, day.month, day.day, 11, 54),
      ),
      PrayerTimeEntry(
        slot: PrayerSlot.isha,
        time: DateTime(day.year, day.month, day.day, 19, 3),
      ),
    ],
  );

  final day6 = scheduleFor(DateTime(2026, 9, 6));
  final day7 = scheduleFor(DateTime(2026, 9, 7));
  final day8 = scheduleFor(DateTime(2026, 9, 8));

  NextPrayerCountdownCubit cubitAt(DateTime now) {
    final cubit = NextPrayerCountdownCubit(FakeClock(now));
    addTearDown(cubit.close);
    return cubit;
  }

  test('emits the next slot and remaining duration immediately', () {
    final cubit = cubitAt(DateTime(2026, 9, 7, 11, 24))
      ..track(today: day7, yesterday: day6, tomorrow: day8);

    expect(cubit.state.phase, CountdownPhase.counting);
    expect(cubit.state.slot, PrayerSlot.dhuhr);
    expect(cubit.state.slotTime, DateTime(2026, 9, 7, 11, 54));
    expect(cubit.state.remaining, const Duration(minutes: 30));
    expect(cubit.state.currentSlot, PrayerSlot.fajr);
    expect(cubit.state.isActive, isTrue);
  });

  test('a 59-second remainder is not reported as zero', () {
    // The bug this replaces: the old formatter floored to whole minutes, so
    // the last 59 seconds before every prayer read "0 menit".
    final cubit = cubitAt(DateTime(2026, 9, 7, 11, 53, 1))..track(today: day7);

    expect(cubit.state.remaining, const Duration(seconds: 59));
    expect(countdownSeconds(cubit.state.remaining!), 59);
    expect(formatCountdown(cubit.state.remaining!), '0:59');
  });

  test('announces a prayer that has just arrived, then moves on', () {
    final clock = FakeClock(DateTime(2026, 9, 7, 11, 54, 30));
    final cubit = NextPrayerCountdownCubit(clock);
    addTearDown(cubit.close);
    cubit.track(today: day7, tomorrow: day8);

    expect(cubit.state.phase, CountdownPhase.arrived);
    expect(cubit.state.slot, PrayerSlot.dhuhr);
    expect(cubit.state.remaining, isNull);
    expect(cubit.state.progress, 1);

    // Past the hold, the hero goes back to counting — to the next prayer.
    clock.setNow(DateTime(2026, 9, 7, 11, 56, 1));
    cubit.tickNow();

    expect(cubit.state.phase, CountdownPhase.counting);
    expect(cubit.state.slot, PrayerSlot.isha);
    expect(cubit.state.currentSlot, PrayerSlot.dhuhr);
  });

  test('after the last prayer it counts to tomorrow, still ticking', () {
    // Before this, the cubit emitted "elapsed" and cancelled its own timer,
    // and nothing ever restarted it: the hero sat dead from Isha until the
    // app was next resumed.
    final clock = FakeClock(DateTime(2026, 9, 7, 20, 0));
    final cubit = NextPrayerCountdownCubit(clock);
    addTearDown(cubit.close);
    cubit.track(today: day7, yesterday: day6, tomorrow: day8);

    expect(cubit.state.phase, CountdownPhase.counting);
    expect(cubit.state.slot, PrayerSlot.fajr);
    expect(cubit.state.slotTime, DateTime(2026, 9, 8, 4, 35));
    expect(cubit.state.remaining, const Duration(hours: 8, minutes: 35));
    expect(cubit.state.needsReload, isFalse);

    // An hour later it is still counting, not stopped.
    clock.setNow(DateTime(2026, 9, 7, 21, 0));
    cubit.tickNow();
    expect(cubit.state.remaining, const Duration(hours: 7, minutes: 35));
  });

  test('asks for a reload once the calendar day moves on', () {
    final clock = FakeClock(DateTime(2026, 9, 7, 20, 0));
    final cubit = NextPrayerCountdownCubit(clock);
    addTearDown(cubit.close);
    cubit.track(today: day7, tomorrow: day8);
    expect(cubit.state.needsReload, isFalse);

    clock.setNow(DateTime(2026, 9, 8, 0, 0, 1));
    cubit.tickNow();

    expect(cubit.state.needsReload, isTrue);
  });

  test('the ring measures Fajr from yesterday evening', () {
    // Fajr's window starts at the previous day's Isha, so without yesterday
    // there is nothing to measure from and the ring must stay empty rather
    // than guess.
    final withYesterday = cubitAt(DateTime(2026, 9, 7, 2, 0))
      ..track(today: day7, yesterday: day6);

    // 19:03 -> 04:35 is 9h32m; 02:00 is 6h57m into it.
    expect(withYesterday.state.progress, closeTo(0.729, 0.01));

    final without = cubitAt(DateTime(2026, 9, 7, 2, 0))..track(today: day7);
    expect(without.state.progress, 0);
  });

  test('emits nothing before it is given a schedule', () {
    final cubit = cubitAt(DateTime(2026, 9, 7, 11, 24));

    expect(cubit.state.phase, CountdownPhase.idle);
    expect(cubit.state.isActive, isFalse);
  });
}
