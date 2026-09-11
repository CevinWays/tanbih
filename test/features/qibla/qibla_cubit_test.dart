import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/error/failures.dart';
import 'package:tanbih/features/prayer_times/domain/repositories/prayer_times_repository.dart';
import 'package:tanbih/features/qibla/domain/compass_port.dart';
import 'package:tanbih/features/qibla/domain/compass_reading.dart';
import 'package:tanbih/features/qibla/presentation/bloc/qibla_cubit.dart';

class MockPrayerTimes extends Mock implements PrayerTimesRepository {}

class MockCompass extends Mock implements CompassPort {}

void main() {
  late MockPrayerTimes prayerTimes;
  late MockCompass compass;

  // Published bearing from Jakarta is about 295 degrees from true north.
  const jakartaBearing = 295.0;

  setUp(() {
    prayerTimes = MockPrayerTimes();
    compass = MockCompass();

    when(
      () => prayerTimes.getQiblaBearing(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) async => const Right(jakartaBearing));

    when(
      () => compass.readings(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) => const Stream.empty());
  });

  QiblaCubit build() => QiblaCubit(prayerTimes, compass);

  Future<void> start(QiblaCubit cubit) =>
      cubit.start(latitude: -6.2088, longitude: 106.8456);

  group('relative bearing', () {
    test('is the qibla bearing minus the heading', () {
      const state = QiblaState(
        bearing: jakartaBearing,
        reading: CompassReading(
          hasSensor: true,
          headingDegrees: 100,
          accuracy: CompassAccuracy.high,
        ),
      );

      expect(state.relativeBearing, 195);
    });

    test('wraps around north rather than going negative', () {
      const state = QiblaState(
        bearing: 10,
        reading: CompassReading(
          hasSensor: true,
          headingDegrees: 350,
          accuracy: CompassAccuracy.high,
        ),
      );

      expect(state.relativeBearing, 20);
    });

    test('is null without a heading, so the screen can show a number', () {
      const state = QiblaState(bearing: jakartaBearing);
      expect(state.relativeBearing, isNull);
      expect(state.isFacingQibla, isFalse);
    });
  });

  group('facing detection', () {
    test('counts as facing within the tolerance, on both sides of zero', () {
      CompassReading at(double heading) => CompassReading(
        hasSensor: true,
        headingDegrees: heading,
        accuracy: CompassAccuracy.high,
      );

      // Dead on, and just inside the tolerance either way.
      expect(
        const QiblaState(
          bearing: jakartaBearing,
        ).copyWith(reading: at(jakartaBearing)).isFacingQibla,
        isTrue,
      );
      expect(
        const QiblaState(
          bearing: jakartaBearing,
        ).copyWith(reading: at(jakartaBearing - 4)).isFacingQibla,
        isTrue,
      );
      expect(
        const QiblaState(
          bearing: jakartaBearing,
        ).copyWith(reading: at(jakartaBearing + 4)).isFacingQibla,
        isTrue,
      );
    });

    test('does not claim facing when clearly off', () {
      expect(
        const QiblaState(
          bearing: jakartaBearing,
          reading: CompassReading(
            hasSensor: true,
            headingDegrees: 200,
            accuracy: CompassAccuracy.high,
          ),
        ).isFacingQibla,
        isFalse,
      );
    });
  });

  group('start', () {
    blocTest<QiblaCubit, QiblaState>(
      'loads the bearing',
      build: build,
      act: start,
      expect: () => [
        isA<QiblaState>().having(
          (s) => s.status,
          'status',
          QiblaStatus.loading,
        ),
        isA<QiblaState>()
            .having((s) => s.status, 'status', QiblaStatus.success)
            .having((s) => s.bearing, 'bearing', jakartaBearing),
      ],
    );

    blocTest<QiblaCubit, QiblaState>(
      'surfaces a bearing failure and never subscribes to the sensor',
      setUp: () => when(
        () => prayerTimes.getQiblaBearing(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => const Left(QiblaFailure())),
      build: build,
      act: start,
      skip: 1,
      expect: () => [
        isA<QiblaState>().having(
          (s) => s.status,
          'status',
          QiblaStatus.failure,
        ),
      ],
      verify: (_) => verifyNever(
        () => compass.readings(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ),
    );

    blocTest<QiblaCubit, QiblaState>(
      'a phone with no magnetometer still gets the bearing',
      setUp: () => when(
        () => compass.readings(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) => Stream.value(const CompassReading.unavailable())),
      build: build,
      act: start,
      wait: const Duration(milliseconds: 50),
      verify: (cubit) {
        expect(cubit.state.bearing, jakartaBearing);
        expect(cubit.state.reading.hasSensor, isFalse);
        expect(cubit.state.relativeBearing, isNull);
      },
    );
  });

  group('CompassAccuracy', () {
    test('maps the platform values', () {
      expect(CompassAccuracy.fromPlatform(3), CompassAccuracy.high);
      expect(CompassAccuracy.fromPlatform(0), CompassAccuracy.unreliable);
      expect(CompassAccuracy.fromPlatform(-1), CompassAccuracy.unavailable);
    });

    test('asks for calibration only when readings cannot be trusted', () {
      expect(CompassAccuracy.unreliable.needsCalibration, isTrue);
      expect(CompassAccuracy.low.needsCalibration, isTrue);
      expect(CompassAccuracy.high.needsCalibration, isFalse);
    });
  });
}
