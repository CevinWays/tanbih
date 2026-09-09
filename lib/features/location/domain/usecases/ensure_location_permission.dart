import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/location_repository.dart';

/// Requests the OS location permission if it has not been asked for yet.
///
/// Called from onboarding so the rationale is shown before the system
/// dialog, as the Play Store policy expects.
@injectable
class EnsureLocationPermission implements UseCase<Unit, NoParams> {
  const EnsureLocationPermission(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.ensurePermission();
}
