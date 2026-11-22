import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../prayer_times/domain/repositories/prayer_times_repository.dart';
import '../entities/qibla_summary.dart';
import '../kaaba.dart';
import 'qibla_params.dart';

/// Bearing and distance to the Kaaba for a position.
///
/// The bearing comes from the prayer-times repository, which owns the only
/// copy of the `adhan` package; the distance is computed here because it
/// needs nothing but arithmetic.
@injectable
class GetQiblaSummary implements UseCase<QiblaSummary, QiblaParams> {
  const GetQiblaSummary(this._repository);

  final PrayerTimesRepository _repository;

  @override
  Future<Either<Failure, QiblaSummary>> call(QiblaParams params) async {
    final bearing = await _repository.getQiblaBearing(
      latitude: params.latitude,
      longitude: params.longitude,
    );

    return bearing.map(
      (degrees) => QiblaSummary(
        bearingDegrees: degrees,
        distanceKm: Kaaba.distanceKmFrom(
          latitude: params.latitude,
          longitude: params.longitude,
        ),
      ),
    );
  }
}
