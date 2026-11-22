import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/error/failures.dart';
import 'package:tanbih/features/qibla/domain/entities/qibla_summary.dart';
import 'package:tanbih/features/qibla/domain/usecases/get_qibla_summary.dart';
import 'package:tanbih/features/qibla/domain/usecases/qibla_params.dart';
import 'package:tanbih/features/qibla/presentation/bloc/qibla_summary_cubit.dart';

class MockGetQiblaSummary extends Mock implements GetQiblaSummary {}

void main() {
  late MockGetQiblaSummary getSummary;

  const malangLat = -7.9666;
  const malangLng = 112.6326;

  setUpAll(() {
    registerFallbackValue(const QiblaParams(latitude: 0, longitude: 0));
  });

  setUp(() => getSummary = MockGetQiblaSummary());

  blocTest<QiblaSummaryCubit, QiblaSummaryState>(
    'carries the bearing and the distance through to success',
    setUp: () => when(() => getSummary(any())).thenAnswer(
      (_) async =>
          const Right(QiblaSummary(bearingDegrees: 294.5, distanceKm: 8581.9)),
    ),
    build: () => QiblaSummaryCubit(getSummary),
    act: (cubit) => cubit.load(latitude: malangLat, longitude: malangLng),
    expect: () => [
      isA<QiblaSummaryState>().having(
        (s) => s.status,
        'status',
        QiblaSummaryStatus.loading,
      ),
      isA<QiblaSummaryState>()
          .having((s) => s.status, 'status', QiblaSummaryStatus.success)
          .having((s) => s.summary?.bearingDegrees, 'bearing', 294.5)
          .having((s) => s.summary?.distanceKm, 'distance', 8581.9),
    ],
    verify: (_) {
      final captured =
          verify(() => getSummary(captureAny())).captured.single as QiblaParams;
      expect(captured.latitude, malangLat);
      expect(captured.longitude, malangLng);
    },
  );

  blocTest<QiblaSummaryCubit, QiblaSummaryState>(
    'reports a failure instead of a bearing',
    setUp: () => when(
      () => getSummary(any()),
    ).thenAnswer((_) async => const Left(QiblaFailure())),
    build: () => QiblaSummaryCubit(getSummary),
    act: (cubit) => cubit.load(latitude: malangLat, longitude: malangLng),
    expect: () => [
      isA<QiblaSummaryState>().having(
        (s) => s.status,
        'status',
        QiblaSummaryStatus.loading,
      ),
      isA<QiblaSummaryState>()
          .having((s) => s.status, 'status', QiblaSummaryStatus.failure)
          .having((s) => s.summary, 'summary', isNull),
    ],
  );
}
