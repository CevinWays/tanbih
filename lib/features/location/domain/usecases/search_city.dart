import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/city.dart';
import '../repositories/location_repository.dart';

/// Online search with the bundled Indonesian dataset as fallback.
///
/// An empty query returns the whole bundled list, so the picker has
/// something to show before the user types.
@injectable
class SearchCity implements UseCase<List<City>, String> {
  const SearchCity(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, List<City>>> call(String params) =>
      _repository.searchCity(params);
}
