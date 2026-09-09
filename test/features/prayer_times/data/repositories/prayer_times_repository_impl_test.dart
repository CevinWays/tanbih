import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/core/error/exceptions.dart';
import 'package:tanbih/core/error/failures.dart';
import 'package:tanbih/core/services/app_context.dart';
import 'package:tanbih/features/prayer_times/data/datasources/adhan_calculator_data_source.dart';
import 'package:tanbih/features/prayer_times/data/datasources/calculation_settings_local_data_source.dart';
import 'package:tanbih/features/prayer_times/data/datasources/hijri_data_source.dart';
import 'package:tanbih/features/prayer_times/data/repositories/prayer_times_repository_impl.dart';
import 'package:tanbih/features/prayer_times/domain/entities/calculation_settings.dart';
import 'package:tanbih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:tanbih/features/prayer_times/domain/entities/hijri_date.dart';

class MockCalculator extends Mock implements AdhanCalculatorDataSource {}

class MockHijri extends Mock implements HijriDataSource {}

class MockSettings extends Mock implements CalculationSettingsLocalDataSource {}

void main() {
  late MockCalculator calculator;
  late MockHijri hijri;
  late MockSettings settingsSource;
  late AppContext appContext;
  late PrayerTimesRepositoryImpl repository;

  const ramadan = HijriDate(
    year: 1448,
    month: 9,
    day: 1,
    monthName: 'Ramadhan',
  );

  DailyPrayerTimes emptyDay(DateTime date) =>
      DailyPrayerTimes(date: date, entries: const [], hijriDate: ramadan);

  setUpAll(() {
    // mocktail needs a fallback for every non-nullable type used with
    // `any(named:)`. Without them the stub setup throws mid-way and leaves
    // the matcher state dirty, which then misreports the *next* call.
    registerFallbackValue(const CalculationSettings());
    registerFallbackValue(ramadan);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    calculator = MockCalculator();
    hijri = MockHijri();
    settingsSource = MockSettings();
    appContext = AppContext();
    repository = PrayerTimesRepositoryImpl(
      calculator,
      hijri,
      settingsSource,
      appContext,
    );

    when(
      () => hijri.convert(
        date: any(named: 'date'),
        offsetDays: any(named: 'offsetDays'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenReturn(ramadan);

    when(
      () => calculator.calculate(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        date: any(named: 'date'),
        timeZoneId: any(named: 'timeZoneId'),
        settings: any(named: 'settings'),
        hijriDate: any(named: 'hijriDate'),
      ),
    ).thenAnswer(
      (invocation) =>
          emptyDay(invocation.namedArguments[const Symbol('date')] as DateTime),
    );
  });

  group('getDailyTimes', () {
    test('resolves the Hijri date before calculating', () async {
      // The Umm al-Qura Ramadan correction needs the Hijri month, so the
      // conversion has to happen first and be handed in.
      await repository.getDailyTimes(
        latitude: -6.2088,
        longitude: 106.8456,
        date: DateTime(2026, 9, 7),
        timeZoneId: 'Asia/Jakarta',
        settings: const CalculationSettings(hijriOffsetDays: -1),
      );

      verify(
        () => hijri.convert(
          date: DateTime(2026, 9, 7),
          offsetDays: -1,
          languageCode: 'id',
        ),
      ).called(1);

      verify(
        () => calculator.calculate(
          latitude: -6.2088,
          longitude: 106.8456,
          date: DateTime(2026, 9, 7),
          timeZoneId: 'Asia/Jakarta',
          settings: any(named: 'settings'),
          hijriDate: ramadan,
        ),
      ).called(1);
    });

    test('maps a CalculationException to a CalculationFailure', () async {
      when(
        () => calculator.calculate(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          date: any(named: 'date'),
          timeZoneId: any(named: 'timeZoneId'),
          settings: any(named: 'settings'),
          hijriDate: any(named: 'hijriDate'),
        ),
      ).thenThrow(const CalculationException(message: 'bad zone'));

      final result = await repository.getDailyTimes(
        latitude: 0,
        longitude: 0,
        date: DateTime(2026, 9, 7),
        timeZoneId: 'Mars/Olympus',
        settings: const CalculationSettings(),
      );

      expect(
        result.fold((f) => f, (_) => null),
        isA<CalculationFailure>().having(
          (f) => f.message,
          'message',
          'bad zone',
        ),
      );
    });

    test('uses the ambient language for Hijri month names', () async {
      appContext.languageCode = 'en';

      await repository.getDailyTimes(
        latitude: 0,
        longitude: 0,
        date: DateTime(2026, 9, 7),
        timeZoneId: 'Asia/Jakarta',
        settings: const CalculationSettings(),
      );

      verify(
        () => hijri.convert(
          date: any(named: 'date'),
          offsetDays: any(named: 'offsetDays'),
          languageCode: 'en',
        ),
      ).called(1);
    });
  });

  group('getRange', () {
    test('returns one entry per day, inclusive of both ends', () async {
      final result = await repository.getRange(
        latitude: 0,
        longitude: 0,
        from: DateTime(2026, 9, 7),
        to: DateTime(2026, 9, 13),
        timeZoneId: 'Asia/Jakarta',
        settings: const CalculationSettings(),
      );

      final days = result.getOrElse(() => []);
      expect(days.length, 7);
      expect(days.first.date, DateTime(2026, 9, 7));
      expect(days.last.date, DateTime(2026, 9, 13));
    });

    test('a single-day range yields one day', () async {
      final result = await repository.getRange(
        latitude: 0,
        longitude: 0,
        from: DateTime(2026, 9, 7),
        to: DateTime(2026, 9, 7),
        timeZoneId: 'Asia/Jakarta',
        settings: const CalculationSettings(),
      );

      expect(result.getOrElse(() => []).length, 1);
    });

    test('crossing a month boundary keeps the days contiguous', () async {
      final result = await repository.getRange(
        latitude: 0,
        longitude: 0,
        from: DateTime(2026, 9, 29),
        to: DateTime(2026, 10, 3),
        timeZoneId: 'Asia/Jakarta',
        settings: const CalculationSettings(),
      );

      final days = result.getOrElse(() => []);
      expect(days.map((d) => d.date), [
        DateTime(2026, 9, 29),
        DateTime(2026, 9, 30),
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 3),
      ]);
    });

    test('rejects a reversed range', () async {
      final result = await repository.getRange(
        latitude: 0,
        longitude: 0,
        from: DateTime(2026, 9, 13),
        to: DateTime(2026, 9, 7),
        timeZoneId: 'Asia/Jakarta',
        settings: const CalculationSettings(),
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('settings', () {
    test('reads through to the local source', () async {
      when(settingsSource.read).thenReturn(const CalculationSettings());

      final result = await repository.getSettings();

      expect(result.isRight(), isTrue);
      verify(settingsSource.read).called(1);
    });

    test('maps a CacheException on write to a CacheFailure', () async {
      when(
        () => settingsSource.write(any()),
      ).thenThrow(const CacheException(message: 'disk full'));

      final result = await repository.saveSettings(const CalculationSettings());

      expect(
        result.fold((f) => f, (_) => null),
        isA<CacheFailure>().having((f) => f.message, 'message', 'disk full'),
      );
    });

    test('a successful write returns unit', () async {
      when(() => settingsSource.write(any())).thenAnswer((_) async {});

      final result = await repository.saveSettings(const CalculationSettings());

      expect(result.isRight(), isTrue);
    });
  });
}
