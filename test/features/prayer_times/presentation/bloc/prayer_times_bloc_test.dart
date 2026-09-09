import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/config/calculation_presets.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/core/error/failures.dart';
import 'package:tanbih/core/services/clock.dart';
import 'package:tanbih/core/usecases/usecase.dart';
import 'package:tanbih/features/prayer_times/domain/entities/calculation_settings.dart';
import 'package:tanbih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:tanbih/features/prayer_times/domain/entities/hijri_date.dart';
import 'package:tanbih/features/prayer_times/domain/entities/prayer_time_entry.dart';
import 'package:tanbih/features/prayer_times/domain/usecases/get_calculation_settings.dart';
import 'package:tanbih/features/prayer_times/domain/usecases/get_prayer_times_for_date.dart';
import 'package:tanbih/features/prayer_times/domain/usecases/prayer_times_params.dart';
import 'package:tanbih/features/prayer_times/domain/usecases/save_calculation_settings.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/prayer_times_event.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/prayer_times_state.dart';

class MockGetPrayerTimesForDate extends Mock implements GetPrayerTimesForDate {}

class MockGetCalculationSettings extends Mock
    implements GetCalculationSettings {}

class MockSaveCalculationSettings extends Mock
    implements SaveCalculationSettings {}

void main() {
  late MockGetPrayerTimesForDate getForDate;
  late MockGetCalculationSettings getSettings;
  late MockSaveCalculationSettings saveSettings;
  late FakeClock clock;

  const jakartaLat = -6.2088;
  const jakartaLng = 106.8456;
  const jakartaZone = 'Asia/Jakarta';

  final today = DateTime(2026, 9, 7);
  final tomorrow = DateTime(2026, 9, 8);

  DailyPrayerTimes scheduleFor(DateTime day) => DailyPrayerTimes(
    date: day,
    hijriDate: const HijriDate(
      year: 1448,
      month: 3,
      day: 1,
      monthName: "Rabi'ul Awal",
    ),
    entries: [
      PrayerTimeEntry(
        slot: PrayerSlot.fajr,
        time: DateTime(day.year, day.month, day.day, 4, 35),
      ),
      PrayerTimeEntry(
        slot: PrayerSlot.dhuhr,
        time: DateTime(day.year, day.month, day.day, 11, 54),
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(
      PrayerTimesForDateParams(
        base: const PrayerTimesParams(
          latitude: 0,
          longitude: 0,
          timeZoneId: 'UTC',
          settings: CalculationSettings(),
        ),
        date: DateTime(2026),
      ),
    );
    registerFallbackValue(const NoParams());
    registerFallbackValue(const CalculationSettings());
  });

  setUp(() {
    getForDate = MockGetPrayerTimesForDate();
    getSettings = MockGetCalculationSettings();
    saveSettings = MockSaveCalculationSettings();
    clock = FakeClock(DateTime(2026, 9, 7, 10));

    when(
      () => getSettings(any()),
    ).thenAnswer((_) async => const Right(CalculationSettings()));
    when(() => saveSettings(any())).thenAnswer((_) async => const Right(unit));
    when(
      () => getForDate(any()),
    ).thenAnswer((_) async => Right(scheduleFor(today)));
  });

  PrayerTimesBloc build() =>
      PrayerTimesBloc(getForDate, getSettings, saveSettings, clock);

  group('load', () {
    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'goes loading then success and retains the location',
      build: build,
      act: (bloc) => bloc.add(
        const PrayerTimesLoadRequested(
          latitude: jakartaLat,
          longitude: jakartaLng,
          timeZoneId: jakartaZone,
        ),
      ),
      expect: () => [
        isA<PrayerTimesState>()
            .having((s) => s.status, 'status', PrayerTimesStatus.loading)
            .having((s) => s.timeZoneId, 'timeZoneId', jakartaZone),
        isA<PrayerTimesState>()
            .having((s) => s.status, 'status', PrayerTimesStatus.success)
            .having((s) => s.hasLocation, 'hasLocation', isTrue)
            .having((s) => s.entries.length, 'entries', 2),
      ],
    );

    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'loads today when no date has been selected yet',
      build: build,
      act: (bloc) => bloc.add(
        const PrayerTimesLoadRequested(
          latitude: jakartaLat,
          longitude: jakartaLng,
          timeZoneId: jakartaZone,
        ),
      ),
      verify: (_) {
        final captured =
            verify(() => getForDate(captureAny())).captured.single
                as PrayerTimesForDateParams;
        expect(captured.date, DateTime(2026, 9, 7));
      },
    );

    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'surfaces a calculation failure',
      setUp: () => when(() => getForDate(any())).thenAnswer(
        (_) async => const Left(CalculationFailure(message: 'bad coords')),
      ),
      build: build,
      act: (bloc) => bloc.add(
        const PrayerTimesLoadRequested(
          latitude: 95,
          longitude: 0,
          timeZoneId: jakartaZone,
        ),
      ),
      skip: 1,
      expect: () => [
        isA<PrayerTimesState>()
            .having((s) => s.status, 'status', PrayerTimesStatus.failure)
            .having((s) => s.failure, 'failure', isA<CalculationFailure>()),
      ],
    );

    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'still produces a schedule when reading settings fails',
      setUp: () => when(
        () => getSettings(any()),
      ).thenAnswer((_) async => const Left(CacheFailure())),
      build: build,
      act: (bloc) => bloc.add(
        const PrayerTimesLoadRequested(
          latitude: jakartaLat,
          longitude: jakartaLng,
          timeZoneId: jakartaZone,
        ),
      ),
      skip: 1,
      expect: () => [
        isA<PrayerTimesState>()
            .having((s) => s.status, 'status', PrayerTimesStatus.success)
            .having(
              (s) => s.settings.method,
              'falls back to the Kemenag default',
              CalculationMethodId.kemenag,
            ),
      ],
    );
  });

  group('date change', () {
    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'recomputes for the new date using the retained location',
      build: build,
      seed: () => PrayerTimesState(
        status: PrayerTimesStatus.success,
        times: scheduleFor(today),
        selectedDate: today,
        latitude: jakartaLat,
        longitude: jakartaLng,
        timeZoneId: jakartaZone,
      ),
      act: (bloc) => bloc.add(PrayerTimesDateChanged(tomorrow)),
      verify: (_) {
        final captured =
            verify(() => getForDate(captureAny())).captured.single
                as PrayerTimesForDateParams;
        expect(captured.date, tomorrow);
        expect(captured.base.timeZoneId, jakartaZone);
      },
    );

    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'without a location it only records the date and does no work',
      build: build,
      act: (bloc) => bloc.add(PrayerTimesDateChanged(tomorrow)),
      expect: () => [
        isA<PrayerTimesState>()
            .having((s) => s.selectedDate, 'selectedDate', tomorrow)
            .having((s) => s.status, 'status', PrayerTimesStatus.initial),
      ],
      verify: (_) => verifyNever(() => getForDate(any())),
    );
  });

  group('settings change', () {
    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'persists the change and recomputes with it',
      build: build,
      seed: () => PrayerTimesState(
        status: PrayerTimesStatus.success,
        times: scheduleFor(today),
        selectedDate: today,
        latitude: jakartaLat,
        longitude: jakartaLng,
        timeZoneId: jakartaZone,
      ),
      act: (bloc) => bloc.add(
        const PrayerTimesSettingsChanged(
          CalculationSettings(madhab: MadhabId.hanafi),
        ),
      ),
      verify: (_) {
        verify(
          () =>
              saveSettings(const CalculationSettings(madhab: MadhabId.hanafi)),
        ).called(1);
        final captured =
            verify(() => getForDate(captureAny())).captured.single
                as PrayerTimesForDateParams;
        expect(captured.base.settings.madhab, MadhabId.hanafi);
      },
    );

    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'applies the new settings even if saving them failed',
      setUp: () => when(
        () => saveSettings(any()),
      ).thenAnswer((_) async => const Left(CacheFailure())),
      build: build,
      seed: () => PrayerTimesState(
        status: PrayerTimesStatus.success,
        times: scheduleFor(today),
        selectedDate: today,
        latitude: jakartaLat,
        longitude: jakartaLng,
        timeZoneId: jakartaZone,
      ),
      act: (bloc) => bloc.add(
        const PrayerTimesSettingsChanged(
          CalculationSettings(madhab: MadhabId.hanafi),
        ),
      ),
      skip: 1,
      expect: () => [
        isA<PrayerTimesState>()
            .having((s) => s.status, 'status', PrayerTimesStatus.success)
            .having((s) => s.settings.madhab, 'madhab', MadhabId.hanafi)
            .having((s) => s.failure, 'reports the save failure', isNotNull),
      ],
    );
  });

  group('today', () {
    blocTest<PrayerTimesBloc, PrayerTimesState>(
      'jumps back to the clock date',
      build: build,
      seed: () => PrayerTimesState(
        status: PrayerTimesStatus.success,
        times: scheduleFor(tomorrow),
        selectedDate: tomorrow,
        latitude: jakartaLat,
        longitude: jakartaLng,
        timeZoneId: jakartaZone,
      ),
      act: (bloc) => bloc.add(const PrayerTimesTodayRequested()),
      verify: (_) {
        final captured =
            verify(() => getForDate(captureAny())).captured.single
                as PrayerTimesForDateParams;
        expect(captured.date, DateTime(2026, 9, 7));
      },
    );
  });
}
