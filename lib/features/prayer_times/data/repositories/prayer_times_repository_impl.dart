import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/app_context.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/calculation_settings.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/repositories/prayer_times_repository.dart';
import '../datasources/adhan_calculator_data_source.dart';
import '../datasources/calculation_settings_local_data_source.dart';
import '../datasources/hijri_data_source.dart';

@LazySingleton(as: PrayerTimesRepository)
class PrayerTimesRepositoryImpl implements PrayerTimesRepository {
  PrayerTimesRepositoryImpl(
    this._calculator,
    this._hijri,
    this._settingsSource,
    this._appContext,
  );

  final AdhanCalculatorDataSource _calculator;
  final HijriDataSource _hijri;
  final CalculationSettingsLocalDataSource _settingsSource;
  final AppContext _appContext;

  @override
  Future<Either<Failure, DailyPrayerTimes>> getDailyTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String timeZoneId,
    required CalculationSettings settings,
  }) async {
    try {
      return Right(
        _calculateOne(latitude, longitude, date, timeZoneId, settings),
      );
    } on CalculationException catch (e) {
      return Left(CalculationFailure(message: e.message));
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyPrayerTimes>>> getRange({
    required double latitude,
    required double longitude,
    required DateTime from,
    required DateTime to,
    required String timeZoneId,
    required CalculationSettings settings,
  }) async {
    if (to.isBefore(from)) {
      return const Left(
        CalculationFailure(message: 'Rentang tanggal tidak valid'),
      );
    }

    try {
      final days = <DailyPrayerTimes>[];
      var cursor = DateTime(from.year, from.month, from.day);
      final last = DateTime(to.year, to.month, to.day);

      while (!cursor.isAfter(last)) {
        days.add(
          _calculateOne(latitude, longitude, cursor, timeZoneId, settings),
        );
        // Add 1 day at midday to stay clear of DST transitions, which can
        // make "+24h" land on the same or the day after next.
        final next = DateTime(
          cursor.year,
          cursor.month,
          cursor.day,
          12,
        ).add(const Duration(days: 1));
        cursor = DateTime(next.year, next.month, next.day);
      }

      return Right(days);
    } on CalculationException catch (e) {
      return Left(CalculationFailure(message: e.message));
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getQiblaBearing({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return Right(
        _calculator.qiblaDirection(latitude: latitude, longitude: longitude),
      );
    } on Object catch (e) {
      return Left(QiblaFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CalculationSettings>> getSettings() async {
    try {
      return Right(_settingsSource.read());
    } on Object catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSettings(
    CalculationSettings settings,
  ) async {
    try {
      await _settingsSource.write(settings);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Object catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  DailyPrayerTimes _calculateOne(
    double latitude,
    double longitude,
    DateTime date,
    String timeZoneId,
    CalculationSettings settings,
  ) {
    // Hijri first: the Umm al-Qura Ramadan correction needs to know whether
    // this date falls in month 9 before the parameters are built.
    final hijriDate = _hijri.convert(
      date: date,
      offsetDays: settings.hijriOffsetDays,
      languageCode: _appContext.languageCode,
    );

    return _calculator.calculate(
      latitude: latitude,
      longitude: longitude,
      date: date,
      timeZoneId: timeZoneId,
      settings: settings,
      hijriDate: hijriDate,
    );
  }
}
