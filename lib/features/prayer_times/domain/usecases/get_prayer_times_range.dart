import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_prayer_times.dart';
import '../repositories/prayer_times_repository.dart';
import 'prayer_times_params.dart';

/// A span of days in one pass.
///
/// The notification scheduler uses this to build its whole window at once
/// instead of recomputing day by day.
@injectable
class GetPrayerTimesRange
    implements UseCase<List<DailyPrayerTimes>, PrayerTimesRangeParams> {
  const GetPrayerTimesRange(this._repository);

  final PrayerTimesRepository _repository;

  @override
  Future<Either<Failure, List<DailyPrayerTimes>>> call(
    PrayerTimesRangeParams params,
  ) => _repository.getRange(
    latitude: params.base.latitude,
    longitude: params.base.longitude,
    from: params.from,
    to: params.to,
    timeZoneId: params.base.timeZoneId,
    settings: params.base.settings,
  );
}
