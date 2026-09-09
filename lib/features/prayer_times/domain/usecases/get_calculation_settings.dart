import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/calculation_settings.dart';
import '../repositories/prayer_times_repository.dart';

@injectable
class GetCalculationSettings implements UseCase<CalculationSettings, NoParams> {
  const GetCalculationSettings(this._repository);

  final PrayerTimesRepository _repository;

  @override
  Future<Either<Failure, CalculationSettings>> call(NoParams params) =>
      _repository.getSettings();
}
