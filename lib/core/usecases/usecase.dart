import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Every use case is a single callable class returning `Either<Failure, T>`.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Synchronous variant, for use cases that only transform already-held data
/// (e.g. deriving the next prayer from a loaded schedule).
abstract class SyncUseCase<T, Params> {
  Either<Failure, T> call(Params params);
}

/// Placeholder for use cases that take no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
