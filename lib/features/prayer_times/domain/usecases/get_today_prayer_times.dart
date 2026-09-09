import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_prayer_times.dart';
import '../repositories/prayer_times_repository.dart';
import 'prayer_times_params.dart';

/// Today's schedule for the given location.
@injectable
class GetTodayPrayerTimes
    implements UseCase<DailyPrayerTimes, PrayerTimesParams> {
  const GetTodayPrayerTimes(this._repository, this._clock);

  final PrayerTimesRepository _repository;
  final Clock _clock;

  @override
  Future<Either<Failure, DailyPrayerTimes>> call(PrayerTimesParams params) =>
      _repository.getDailyTimes(
        latitude: params.latitude,
        longitude: params.longitude,
        date: _clock.today(),
        timeZoneId: params.timeZoneId,
        settings: params.settings,
      );
}
