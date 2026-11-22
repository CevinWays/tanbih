import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/l10n/generated/app_localizations.dart';
import 'package:tanbih/core/styles/styles.dart';
import 'package:tanbih/features/prayer_times/presentation/widgets/home_header.dart';

/// Every tappable control has to clear the 48dp floor.
///
/// The design draws its icons at 20-24dp. Shipped that way, the header
/// buttons were 24dp targets — hard to hit with a thumb, and on the test
/// device they could not be hit reliably at all.
void main() {
  Widget wrap(Widget child) => MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('id'), Locale('en')],
    theme: AppTheme.light,
    home: Scaffold(body: child),
  );

  testWidgets('the header action buttons are at least 48dp', (tester) async {
    await tester.pumpWidget(
      wrap(
        HomeHeader(
          locationLabel: 'Malang',
          date: DateTime(2026, 9, 7),
          hijriDate: null,
          onSettingsTap: () {},
          onMenuTap: () {},
          child: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final buttons = find.byType(InkResponse);
    expect(buttons, findsWidgets);

    for (final element in buttons.evaluate()) {
      final size = tester.getSize(find.byWidget(element.widget));
      expect(size.width, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
      expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
    }
  });
}
