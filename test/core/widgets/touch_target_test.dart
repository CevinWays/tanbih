import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/error/failures.dart';
import 'package:tanbih/core/l10n/generated/app_localizations.dart';
import 'package:tanbih/core/styles/styles.dart';
import 'package:tanbih/features/prayer_times/presentation/widgets/home_header.dart';
import 'package:tanbih/features/qibla/domain/entities/qibla_summary.dart';
import 'package:tanbih/features/qibla/domain/usecases/get_qibla_summary.dart';
import 'package:tanbih/features/qibla/domain/usecases/qibla_params.dart';
import 'package:tanbih/features/qibla/presentation/bloc/qibla_summary_cubit.dart';
import 'package:tanbih/features/qibla/presentation/widgets/qibla_summary_row.dart';

class MockGetQiblaSummary extends Mock implements GetQiblaSummary {}

/// Every tappable control has to clear the 48dp floor.
///
/// The design draws its icons at 20-24dp. Shipped that way, the header
/// buttons were 24dp targets — hard to hit with a thumb, and on the test
/// device they could not be hit reliably at all.
void main() {
  setUpAll(() {
    registerFallbackValue(const QiblaParams(latitude: 0, longitude: 0));
  });

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

  testWidgets('the qibla summary row is at least 48dp', (tester) async {
    final getSummary = MockGetQiblaSummary();
    when(() => getSummary(any())).thenAnswer(
      (_) async => const Right<Failure, QiblaSummary>(
        QiblaSummary(bearingDegrees: 294.5, distanceKm: 8581.9),
      ),
    );

    final cubit = QiblaSummaryCubit(getSummary);
    addTearDown(cubit.close);
    await cubit.load(latitude: -7.9666, longitude: 112.6326);

    await tester.pumpWidget(
      wrap(
        Center(
          child: SizedBox(
            width: AppSpacing.maxContentWidth,
            child: BlocProvider.value(
              value: cubit,
              child: const QiblaSummaryRow(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byType(InkWell));
    expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
  });
}
