import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_prayer_times.dart';
import '../repositories/prayer_times_repository.dart';
import 'prayer_times_params.dart';

/// Schedule for an arbitrary date — used when browsing days.
@injectable
class GetPrayerTimesForDate
    implements UseCase<DailyPrayerTimes, PrayerTimesForDateParams> {
  const GetPrayerTimesForDate(this._repository);

  final PrayerTimesRepository _repository;

  @override
  Future<Either<Failure, DailyPrayerTimes>> call(
    PrayerTimesForDateParams params,
  ) => _repository.getDailyTimes(
    latitude: params.base.latitude,
    longitude: params.base.longitude,
    date: params.date,
    timeZoneId: params.base.timeZoneId,
    settings: params.base.settings,
  );
}
