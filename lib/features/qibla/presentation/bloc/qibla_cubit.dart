import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../prayer_times/domain/repositories/prayer_times_repository.dart';
import '../../domain/compass_port.dart';
import '../../domain/compass_reading.dart';

enum QiblaStatus { initial, loading, success, failure }

class QiblaState extends Equatable {
  const QiblaState({
    this.status = QiblaStatus.initial,
    this.bearing,
    this.reading = const CompassReading.unavailable(),
    this.failure,
  });

  final QiblaStatus status;

  /// Direction of the Kaaba, degrees clockwise from true north.
  final double? bearing;

  final CompassReading reading;
  final Failure? failure;

  /// Where to point the needle relative to the top of the screen.
  ///
  /// Null without a heading — the screen then shows the bearing as a number,
  /// which is still usable with any separate compass.
  double? get relativeBearing {
    final target = bearing;
    final heading = reading.headingDegrees;
    if (target == null || heading == null) return null;
    return (target - heading + 360) % 360;
  }

  /// True when the phone is pointing close enough to call it facing Makkah.
  ///
  /// Five degrees is well inside the error of a phone magnetometer, so a
  /// tighter figure would promise precision the hardware cannot deliver.
  bool get isFacingQibla {
    final relative = relativeBearing;
    if (relative == null) return false;
    final off = relative > 180 ? 360 - relative : relative;
    return off <= facingToleranceDegrees;
  }

  static const double facingToleranceDegrees = 5;

  QiblaState copyWith({
    QiblaStatus? status,
    double? bearing,
    CompassReading? reading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return QiblaState(
      status: status ?? this.status,
      bearing: bearing ?? this.bearing,
      reading: reading ?? this.reading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, bearing, reading, failure];
}

/// Combines a fixed qibla bearing with a live heading.
@injectable
class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit(this._prayerTimes, this._compass) : super(const QiblaState());

  final PrayerTimesRepository _prayerTimes;
  final CompassPort _compass;

  StreamSubscription<CompassReading>? _subscription;

  Future<void> start({
    required double latitude,
    required double longitude,
  }) async {
    emit(state.copyWith(status: QiblaStatus.loading, clearFailure: true));

    final bearing = await _prayerTimes.getQiblaBearing(
      latitude: latitude,
      longitude: longitude,
    );

    bearing.fold(
      (failure) =>
          emit(state.copyWith(status: QiblaStatus.failure, failure: failure)),
      (value) =>
          emit(state.copyWith(status: QiblaStatus.success, bearing: value)),
    );

    if (bearing.isLeft()) return;

    await _subscription?.cancel();
    _subscription = _compass
        .readings(latitude: latitude, longitude: longitude)
        .listen(
          (reading) => emit(state.copyWith(reading: reading)),
          // A sensor error leaves the bearing on screen: the number alone is
          // still useful, so it must not tear down the whole screen.
          onError: (Object _) =>
              emit(state.copyWith(reading: const CompassReading.unavailable())),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
