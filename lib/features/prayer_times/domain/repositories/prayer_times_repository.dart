import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/calculation_settings.dart';
import '../entities/daily_prayer_times.dart';

/// Prayer time computation and the settings that drive it.
///
/// Every method is offline. Nothing here may touch `core/network/`.
abstract class PrayerTimesRepository {
  /// Times for a single day.
  ///
  /// [timeZoneId] is an IANA zone name. Times belong to the *location's*
  /// zone, not the device's, so a misconfigured phone clock or a manually
  /// picked city abroad cannot shift the schedule.
  Future<Either<Failure, DailyPrayerTimes>> getDailyTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String timeZoneId,
    required CalculationSettings settings,
  });

  /// Times for an inclusive date range. Used by the scheduler to build its
  /// multi-day notification window in one pass.
  Future<Either<Failure, List<DailyPrayerTimes>>> getRange({
    required double latitude,
    required double longitude,
    required DateTime from,
    required DateTime to,
    required String timeZoneId,
    required CalculationSettings settings,
  });

  /// Qibla bearing in degrees clockwise from **true** north.
  ///
  /// Lives here because it comes from the same astronomical package as the
  /// prayer times, and that package is confined to one data source.
  Future<Either<Failure, double>> getQiblaBearing({
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, CalculationSettings>> getSettings();

  Future<Either<Failure, Unit>> saveSettings(CalculationSettings settings);
}
