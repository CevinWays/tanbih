import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/core/l10n/generated/app_localizations.dart';
import 'package:tanbih/core/styles/styles.dart';
import 'package:tanbih/features/prayer_times/domain/entities/prayer_time_entry.dart';
import 'package:tanbih/features/prayer_times/presentation/widgets/prayer_row_tile.dart';
import 'package:tanbih/features/prayer_times/presentation/widgets/prayer_schedule_card.dart';

void main() {
  final entries = [
    PrayerTimeEntry(slot: PrayerSlot.fajr, time: DateTime(2026, 9, 7, 4, 35)),
    PrayerTimeEntry(slot: PrayerSlot.dhuhr, time: DateTime(2026, 9, 7, 11, 54)),
    PrayerTimeEntry(slot: PrayerSlot.asr, time: DateTime(2026, 9, 7, 15, 11)),
    PrayerTimeEntry(
      slot: PrayerSlot.maghrib,
      time: DateTime(2026, 9, 7, 17, 55),
    ),
    PrayerTimeEntry(slot: PrayerSlot.isha, time: DateTime(2026, 9, 7, 19, 3)),
  ];

  Widget wrap(
    Widget child, {
    ThemeData? theme,
    double width = AppSpacing.maxContentWidth,
    TextScaler textScaler = TextScaler.noScaling,
  }) => MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('id'), Locale('en')],
    theme: theme ?? AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  );

  testWidgets('five prayers make five rows and exactly four rules', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(PrayerScheduleCard(entries: entries)));
    await tester.pumpAndSettle();

    expect(find.byType(PrayerRowTile), findsNWidgets(5));
    expect(find.byType(Divider), findsNWidgets(4));
  });

  testWidgets('the fasting pair adds a row and a rule of its own', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        PrayerScheduleCard(
          entries: entries,
          suhoor: DateTime(2026, 9, 7, 4, 25),
          iftaar: DateTime(2026, 9, 7, 17, 55),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Imsak'), findsOneWidget);
    expect(find.text('Berbuka'), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(5));
  });

  testWidgets('the whole list costs one blur, not one per row', (tester) async {
    // The reason the rows were grouped at all: each BackdropFilter forces a
    // read-back of the layer beneath it, and the previous layout put six of
    // them in the body of a screen budgeted for about three in total.
    await tester.pumpWidget(wrap(PrayerScheduleCard(entries: entries)));
    await tester.pumpAndSettle();

    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('marks exactly one row, or none', (tester) async {
    await tester.pumpWidget(
      wrap(PrayerScheduleCard(entries: entries, currentSlot: PrayerSlot.asr)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(PrayerRowTile.markerKey), findsOneWidget);

    await tester.pumpWidget(wrap(PrayerScheduleCard(entries: entries)));
    await tester.pumpAndSettle();
    expect(find.byKey(PrayerRowTile.markerKey), findsNothing);
  });

  testWidgets('survives a narrow screen at double text size', (tester) async {
    // The rows set a minimum height rather than a fixed one precisely so
    // this configuration grows instead of overflowing.
    tester.view.physicalSize = const Size(320, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(
        PrayerScheduleCard(entries: entries, currentSlot: PrayerSlot.asr),
        width: 280,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders on both themes', (tester) async {
    // The rules between rows used to be a hardcoded light colour, which was
    // all but invisible on the dark card.
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(
        wrap(PrayerScheduleCard(entries: entries), theme: theme),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
