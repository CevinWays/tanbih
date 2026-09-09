import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prayer_location.dart';
import '../repositories/location_repository.dart';

/// The stored location, for rendering something immediately on a cold start
/// and for working with no connection at all.
@injectable
class GetCachedLocation implements UseCase<PrayerLocation, NoParams> {
  const GetCachedLocation(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, PrayerLocation>> call(NoParams params) =>
      _repository.getCached();
}
