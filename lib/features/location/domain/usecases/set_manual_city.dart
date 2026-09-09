import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/city.dart';
import '../entities/prayer_location.dart';
import '../repositories/location_repository.dart';

@injectable
class SetManualCity implements UseCase<PrayerLocation, City> {
  const SetManualCity(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, PrayerLocation>> call(City params) =>
      _repository.setManualCity(params);
}
