import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/core/l10n/generated/app_localizations.dart';
import 'package:tanbih/core/services/clock.dart';
import 'package:tanbih/core/styles/styles.dart';
import 'package:tanbih/core/widgets/progress_ring.dart';
import 'package:tanbih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:tanbih/features/prayer_times/domain/entities/hijri_date.dart';
import 'package:tanbih/features/prayer_times/domain/entities/prayer_time_entry.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/next_prayer_countdown_cubit.dart';
import 'package:tanbih/features/prayer_times/presentation/widgets/prayer_countdown_hero.dart';

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

  final day7 = scheduleFor(DateTime(2026, 9, 7));
  final day8 = scheduleFor(DateTime(2026, 9, 8));

  /// A cubit holding one computed state, with its timer stopped.
  ///
  /// `track` emits immediately and only then starts ticking, so stopping it
  /// leaves exactly the state under test — and a widget test must not finish
  /// with a periodic timer still pending.
  NextPrayerCountdownCubit seeded(
    DateTime now, {
    DailyPrayerTimes? today,
    DailyPrayerTimes? tomorrow,
  }) {
    final cubit = NextPrayerCountdownCubit(FakeClock(now));
    addTearDown(cubit.close);
    if (today != null) {
      cubit
        ..track(today: today, tomorrow: tomorrow)
        ..stop();
    }
    return cubit;
  }

  Widget wrap(
    NextPrayerCountdownCubit cubit, {
    TextScaler textScaler = TextScaler.noScaling,
  }) => MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('id'), Locale('en')],
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: const PrayerCountdownHero(),
          ),
        ),
      ),
    ),
  );

  testWidgets('shows the prayer, the countdown and the clock time', (
    tester,
  ) async {
    final cubit = seeded(
      DateTime(2026, 9, 7, 11, 24),
      today: day7,
      tomorrow: day8,
    );

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Dzuhur'), findsOneWidget);
    expect(find.text('30:00'), findsOneWidget);
    expect(find.text('11.54'), findsOneWidget);
    expect(find.byType(ProgressRing), findsOneWidget);
  });

  testWidgets('says it is time when a prayer has just arrived', (tester) async {
    final cubit = seeded(
      DateTime(2026, 9, 7, 11, 54, 30),
      today: day7,
      tomorrow: day8,
    );

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Dzuhur'), findsOneWidget);
    expect(find.text('Sudah masuk waktu'), findsOneWidget);
  });

  testWidgets('the longest value fits the circle, even at double text size', (
    tester,
  ) async {
    // Both axes have bitten in practice: an hours-long value is three
    // glyphs wider than a minutes-only one, and a raised system font size
    // made the three lines taller than the circle.
    final cubit = seeded(
      DateTime(2026, 9, 7, 20, 0),
      today: day7,
      tomorrow: day8,
    );

    expect(cubit.state.slot, PrayerSlot.fajr);

    await tester.pumpWidget(
      wrap(cubit, textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('8:35:00'), findsOneWidget);

    final size = tester.getSize(find.byType(PrayerCountdownHero));
    expect(size.width, AppSpacing.countdownDiameter);
    expect(size.height, AppSpacing.countdownDiameter);
  });

  testWidgets('renders nothing before a schedule arrives', (tester) async {
    await tester.pumpWidget(wrap(seeded(DateTime(2026, 9, 7, 11, 24))));
    await tester.pumpAndSettle();

    expect(find.byType(Text), findsNothing);
  });
}
