import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/l10n/generated/app_localizations.dart';
import 'package:tanbih/core/styles/styles.dart';
import 'package:tanbih/core/widgets/glass_icon_button.dart';

/// Every tappable icon has to clear the 48dp floor.
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
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('the carousel chevron is at least 48dp', (tester) async {
    await tester.pumpWidget(
      wrap(
        const GlassIconButton(
          assetName: 'chevron_right',
          semanticLabel: 'next',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byType(InkWell));
    expect(size.width, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
    expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
  });
}
