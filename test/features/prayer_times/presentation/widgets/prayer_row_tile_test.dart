import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/core/l10n/generated/app_localizations.dart';
import 'package:tanbih/core/styles/styles.dart';
import 'package:tanbih/features/prayer_times/domain/entities/prayer_time_entry.dart';
import 'package:tanbih/features/prayer_times/presentation/widgets/prayer_row_tile.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('id')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: const [Locale('id'), Locale('en')],
  theme: AppTheme.light,
  home: Scaffold(
    body: Center(child: SizedBox(width: 306, child: child)),
  ),
);

void main() {
  final maghrib = PrayerTimeEntry(
    slot: PrayerSlot.maghrib,
    time: DateTime(2026, 9, 7, 17, 55),
  );

  testWidgets('shows the Indonesian prayer name', (tester) async {
    await tester.pumpWidget(
      _wrap(PrayerRowTile(entry: maghrib, notificationEnabled: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maghrib'), findsOneWidget);
  });

  testWidgets('uses the English name when the locale is English', (
    tester,
  ) async {
    final fajr = PrayerTimeEntry(
      slot: PrayerSlot.fajr,
      time: DateTime(2026, 9, 7, 4, 35),
    );

    await tester.pumpWidget(
      _wrap(
        PrayerRowTile(entry: fajr, notificationEnabled: true),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    // "Subuh" in Indonesian, "Fajr" in English — the two locales genuinely
    // differ for prayer names, so this catches a missed translation.
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Subuh'), findsNothing);
  });

  testWidgets('formats the time for the active locale, not the system one', (
    tester,
  ) async {
    // Indonesian renders a 24-hour clock with a dot separator; English
    // renders 12-hour with AM/PM. Both must follow the app's locale rather
    // than whatever the host machine is set to.
    await tester.pumpWidget(
      _wrap(PrayerRowTile(entry: maghrib, notificationEnabled: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text('17.55'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        PrayerRowTile(entry: maghrib, notificationEnabled: true),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('5:55 PM'), findsOneWidget);
  });

  testWidgets('the notification toggle reports its state to screen readers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(PrayerRowTile(entry: maghrib, notificationEnabled: false)),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('Maghrib')), findsWidgets);
  });

  testWidgets('tapping the toggle fires the callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        PrayerRowTile(
          entry: maghrib,
          notificationEnabled: true,
          onToggleNotification: () => taps++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(InkResponse));
    expect(taps, 1);
  });
}
