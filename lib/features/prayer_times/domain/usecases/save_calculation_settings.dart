import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/calculation_settings.dart';
import '../repositories/prayer_times_repository.dart';

@injectable
class SaveCalculationSettings implements UseCase<Unit, CalculationSettings> {
  const SaveCalculationSettings(this._repository);

  final PrayerTimesRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(CalculationSettings params) =>
      _repository.saveSettings(params);
}
