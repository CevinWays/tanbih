import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/core/services/clock.dart';
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

  test('emits the next slot and remaining duration immediately', () {
    final clock = FakeClock(DateTime(2026, 9, 7, 11, 24));
    final cubit = NextPrayerCountdownCubit(clock)
      ..track(scheduleFor(DateTime(2026, 9, 7)));

    expect(cubit.state.slot, PrayerSlot.dhuhr);
    expect(cubit.state.remaining, const Duration(minutes: 30));
    expect(cubit.state.isActive, isTrue);

    cubit.close();
  });

  test('reports elapsed and stops once the day has no prayer left', () {
    final clock = FakeClock(DateTime(2026, 9, 7, 20));
    final cubit = NextPrayerCountdownCubit(clock)
      ..track(scheduleFor(DateTime(2026, 9, 7)));

    expect(cubit.state.elapsed, isTrue);
    expect(cubit.state.slot, isNull);
    expect(cubit.state.isActive, isFalse);

    cubit.close();
  });

  test('re-tracking replaces the previous schedule', () {
    final clock = FakeClock(DateTime(2026, 9, 7, 3));
    final cubit = NextPrayerCountdownCubit(clock)
      ..track(scheduleFor(DateTime(2026, 9, 7)));

    expect(cubit.state.slot, PrayerSlot.fajr);

    // Move past Fajr and hand over tomorrow's schedule, as the bloc does at
    // the day boundary.
    clock.setNow(DateTime(2026, 9, 8, 3));
    cubit.track(scheduleFor(DateTime(2026, 9, 8)));

    expect(cubit.state.slot, PrayerSlot.fajr);
    expect(cubit.state.remaining, const Duration(hours: 1, minutes: 35));

    cubit.close();
  });

  test('emits nothing before a schedule is tracked', () {
    final cubit = NextPrayerCountdownCubit(FakeClock(DateTime(2026, 9, 7)));
    expect(cubit.state, const CountdownState());
    expect(cubit.state.isActive, isFalse);
    cubit.close();
  });
}
