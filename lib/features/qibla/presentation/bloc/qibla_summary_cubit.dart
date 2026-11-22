import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/qibla_summary.dart';
import '../../domain/usecases/get_qibla_summary.dart';
import '../../domain/usecases/qibla_params.dart';

enum QiblaSummaryStatus { initial, loading, success, failure }

class QiblaSummaryState extends Equatable {
  const QiblaSummaryState({
    this.status = QiblaSummaryStatus.initial,
    this.summary,
    this.failure,
  });

  final QiblaSummaryStatus status;
  final QiblaSummary? summary;
  final Failure? failure;

  QiblaSummaryState copyWith({
    QiblaSummaryStatus? status,
    QiblaSummary? summary,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return QiblaSummaryState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, summary, failure];
}

/// The qibla as a pair of numbers, with no compass attached.
///
/// Deliberately not `QiblaCubit`: that one opens the magnetometer stream as
/// soon as a bearing resolves, and emits on every sensor sample. On Home,
/// where no needle is drawn, that would burn the sensor and rebuild a widget
/// next to a `BackdropFilter` dozens of times a second. Having no
/// `CompassPort` here makes that waste impossible rather than merely
/// discouraged.
@injectable
class QiblaSummaryCubit extends Cubit<QiblaSummaryState> {
  QiblaSummaryCubit(this._getSummary) : super(const QiblaSummaryState());

  final GetQiblaSummary _getSummary;

  Future<void> load({
    required double latitude,
    required double longitude,
  }) async {
    emit(
      state.copyWith(status: QiblaSummaryStatus.loading, clearFailure: true),
    );

    final result = await _getSummary(
      QiblaParams(latitude: latitude, longitude: longitude),
    );

    emit(
      result.fold(
        (failure) => state.copyWith(
          status: QiblaSummaryStatus.failure,
          failure: failure,
        ),
        (summary) => state.copyWith(
          status: QiblaSummaryStatus.success,
          summary: summary,
        ),
      ),
    );
  }
}
