import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/error/failures.dart';
import 'package:tanbih/core/l10n/generated/app_localizations.dart';
import 'package:tanbih/core/styles/styles.dart';
import 'package:tanbih/core/widgets/glass_card.dart';
import 'package:tanbih/features/qibla/domain/entities/qibla_summary.dart';
import 'package:tanbih/features/qibla/domain/usecases/get_qibla_summary.dart';
import 'package:tanbih/features/qibla/domain/usecases/qibla_params.dart';
import 'package:tanbih/features/qibla/presentation/bloc/qibla_summary_cubit.dart';
import 'package:tanbih/features/qibla/presentation/widgets/qibla_summary_row.dart';

class MockGetQiblaSummary extends Mock implements GetQiblaSummary {}

void main() {
  setUpAll(() {
    registerFallbackValue(const QiblaParams(latitude: 0, longitude: 0));
  });

  Widget wrap(QiblaSummaryCubit cubit, {Locale locale = const Locale('id')}) =>
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('id'), Locale('en')],
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
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

  Future<QiblaSummaryCubit> loaded(Either<Failure, QiblaSummary> result) async {
    final getSummary = MockGetQiblaSummary();
    when(() => getSummary(any())).thenAnswer((_) async => result);
    final cubit = QiblaSummaryCubit(getSummary);
    addTearDown(cubit.close);
    await cubit.load(latitude: -7.9666, longitude: 112.6326);
    return cubit;
  }

  testWidgets('groups the distance the way each locale writes numbers', (
    tester,
  ) async {
    // The one thing a plain '$km km' gets silently wrong: Indonesian groups
    // thousands with a dot, English with a comma.
    final cubit = await loaded(
      const Right(QiblaSummary(bearingDegrees: 294.5, distanceKm: 8581.9)),
    );

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();
    expect(find.text('295° · 8.582 km ke Makkah'), findsOneWidget);

    await tester.pumpWidget(wrap(cubit, locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('295° · 8,582 km to Makkah'), findsOneWidget);
  });

  testWidgets('says so, and stays inert, while the bearing is pending', (
    tester,
  ) async {
    final getSummary = MockGetQiblaSummary();
    final cubit = QiblaSummaryCubit(getSummary);
    addTearDown(cubit.close);

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Menghitung…'), findsOneWidget);
    expect(tester.widget<GlassCard>(find.byType(GlassCard)).onTap, isNull);
  });

  testWidgets('renders nothing at all when the bearing failed', (tester) async {
    // Home already shows a location failure card; a second apology below it
    // would just be noise.
    final cubit = await loaded(const Left(QiblaFailure()));

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.byType(GlassCard), findsNothing);
  });

  testWidgets('does not pretend to a distance at the Kaaba', (tester) async {
    final cubit = await loaded(
      const Right(QiblaSummary(bearingDegrees: 0, distanceKm: 0.2)),
    );

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Kamu di Makkah'), findsOneWidget);
  });
}
