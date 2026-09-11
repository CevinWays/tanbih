import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/core/l10n/generated/app_localizations.dart';
import 'package:tanbih/core/styles/styles.dart';
import 'package:tanbih/features/prayer_times/domain/entities/prayer_time_entry.dart';
import 'package:tanbih/features/prayer_times/presentation/widgets/prayer_countdown_carousel.dart';

void main() {
  final entries = [
    PrayerTimeEntry(slot: PrayerSlot.fajr, time: DateTime(2026, 9, 11, 4, 10)),
    PrayerTimeEntry(
      slot: PrayerSlot.dhuhr,
      time: DateTime(2026, 9, 11, 11, 30),
    ),
    PrayerTimeEntry(slot: PrayerSlot.asr, time: DateTime(2026, 9, 11, 14, 47)),
    PrayerTimeEntry(
      slot: PrayerSlot.maghrib,
      time: DateTime(2026, 9, 11, 17, 31),
    ),
    PrayerTimeEntry(slot: PrayerSlot.isha, time: DateTime(2026, 9, 11, 18, 39)),
  ];

  Widget wrap({
    PrayerSlot? nextSlot,
    Duration? remaining,
    bool withEntries = true,
  }) => MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('id'), Locale('en')],
    theme: AppTheme.light,
    home: Scaffold(
      body: PrayerCountdownCarousel(
        entries: withEntries ? entries : const [],
        nextSlot: nextSlot,
        remaining: remaining,
      ),
    ),
  );

  testWidgets('opens on the next prayer in the real startup order', (
    tester,
  ) async {
    // This is the sequence the device actually produces: no schedule yet,
    // then the schedule, then the countdown target a frame later. An earlier
    // version of this test started with entries already present, which built
    // the PageView immediately and hid the bug — on the device the carousel
    // sat on Fajr, hours after Fajr had passed.
    await tester.pumpWidget(wrap(withEntries: false));
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsNothing);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      wrap(
        nextSlot: PrayerSlot.maghrib,
        remaining: const Duration(minutes: 58),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('58 min'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
  });

  testWidgets('also lands on the target when both arrive together', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(withEntries: false));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      wrap(nextSlot: PrayerSlot.isha, remaining: const Duration(hours: 2)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Isha'), findsOneWidget);
  });

  testWidgets('a page that is not the target shows its clock time', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        nextSlot: PrayerSlot.maghrib,
        remaining: const Duration(minutes: 58),
      ),
    );
    await tester.pumpAndSettle();

    // "Remaining" is meaningless for a prayer two steps away, so other pages
    // show the time instead.
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Isha'), findsOneWidget);
    expect(find.text('6:39 PM'), findsOneWidget);
    expect(find.text('Remaining'), findsNothing);
  });

  testWidgets('renders nothing tall when there are no entries', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('id'), Locale('en')],
        home: const Scaffold(
          body: PrayerCountdownCarousel(
            entries: [],
            nextSlot: null,
            remaining: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsNothing);
  });
}
