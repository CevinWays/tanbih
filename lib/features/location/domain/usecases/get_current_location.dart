import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prayer_location.dart';
import '../repositories/location_repository.dart';

@injectable
class GetCurrentLocation implements UseCase<PrayerLocation, NoParams> {
  const GetCurrentLocation(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, PrayerLocation>> call(NoParams params) =>
      _repository.getCurrent();
}
