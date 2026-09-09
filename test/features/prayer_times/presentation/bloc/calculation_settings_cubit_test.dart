import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/config/calculation_presets.dart';
import 'package:tanbih/core/error/failures.dart';
import 'package:tanbih/core/usecases/usecase.dart';
import 'package:tanbih/features/prayer_times/domain/entities/calculation_settings.dart';
import 'package:tanbih/features/prayer_times/domain/usecases/get_calculation_settings.dart';
import 'package:tanbih/features/prayer_times/domain/usecases/save_calculation_settings.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/calculation_settings_cubit.dart';

class MockGet extends Mock implements GetCalculationSettings {}

class MockSave extends Mock implements SaveCalculationSettings {}

void main() {
  late MockGet get;
  late MockSave save;

  const hanafi = CalculationSettings(madhab: MadhabId.hanafi);

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const CalculationSettings());
  });

  setUp(() {
    get = MockGet();
    save = MockSave();
    when(
      () => get(any()),
    ).thenAnswer((_) async => const Right(CalculationSettings()));
    when(() => save(any())).thenAnswer((_) async => const Right(unit));
  });

  CalculationSettingsCubit build() => CalculationSettingsCubit(get, save);

  blocTest<CalculationSettingsCubit, CalculationSettingsState>(
    'load reads the stored settings',
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<CalculationSettingsState>().having(
        (s) => s.status,
        'status',
        CalculationSettingsStatus.loading,
      ),
      isA<CalculationSettingsState>()
          .having((s) => s.status, 'status', CalculationSettingsStatus.success)
          .having(
            (s) => s.settings.method,
            'method',
            CalculationMethodId.kemenag,
          ),
    ],
  );

  blocTest<CalculationSettingsCubit, CalculationSettingsState>(
    'update applies the change before persisting it',
    build: build,
    act: (cubit) => cubit.update(hanafi),
    expect: () => [
      isA<CalculationSettingsState>()
          .having((s) => s.settings, 'settings', hanafi)
          .having((s) => s.failure, 'failure', isNull),
    ],
    verify: (_) => verify(() => save(hanafi)).called(1),
  );

  blocTest<CalculationSettingsCubit, CalculationSettingsState>(
    'a failed write keeps the new value and reports the failure',
    setUp: () => when(
      () => save(any()),
    ).thenAnswer((_) async => const Left(CacheFailure())),
    build: build,
    act: (cubit) => cubit.update(hanafi),
    expect: () => [
      // Applied first...
      isA<CalculationSettingsState>()
          .having((s) => s.settings, 'settings', hanafi)
          .having((s) => s.failure, 'failure', isNull),
      // ...then the storage problem surfaces, without reverting the choice
      // the user just made.
      isA<CalculationSettingsState>()
          .having((s) => s.settings, 'settings', hanafi)
          .having((s) => s.failure, 'failure', isA<CacheFailure>()),
    ],
  );

  blocTest<CalculationSettingsCubit, CalculationSettingsState>(
    'a failed read surfaces as failure with defaults intact',
    setUp: () => when(
      () => get(any()),
    ).thenAnswer((_) async => const Left(CacheFailure())),
    build: build,
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => [
      isA<CalculationSettingsState>()
          .having((s) => s.status, 'status', CalculationSettingsStatus.failure)
          .having(
            (s) => s.settings.method,
            'still usable defaults',
            CalculationMethodId.kemenag,
          ),
    ],
  );
}
