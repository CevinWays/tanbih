import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/calculation_settings.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/usecases/get_calculation_settings.dart';
import '../../domain/usecases/get_prayer_times_range.dart';
import '../../domain/usecases/prayer_times_params.dart';

enum MonthlyScheduleStatus { initial, loading, success, failure }

class MonthlyScheduleState extends Equatable {
  const MonthlyScheduleState({
    this.status = MonthlyScheduleStatus.initial,
    this.days = const [],
    this.month,
    this.today,
    this.failure,
  });

  final MonthlyScheduleStatus status;
  final List<DailyPrayerTimes> days;

  /// First day of the month being shown.
  final DateTime? month;

  /// Midnight today, resolved from the injected clock so the table can pick
  /// out the current row without any widget reading the clock itself.
  final DateTime? today;

  final Failure? failure;

  MonthlyScheduleState copyWith({
    MonthlyScheduleStatus? status,
    List<DailyPrayerTimes>? days,
    DateTime? month,
    DateTime? today,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return MonthlyScheduleState(
      status: status ?? this.status,
      days: days ?? this.days,
      month: month ?? this.month,
      today: today ?? this.today,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, days, month, today, failure];
}

/// A whole month of prayer times for the All Prayer table.
///
/// Uses the range use case so the month is computed in one pass rather than
/// thirty separate calls.
@injectable
class MonthlyScheduleCubit extends Cubit<MonthlyScheduleState> {
  MonthlyScheduleCubit(this._getRange, this._getSettings, this._clock)
    : super(const MonthlyScheduleState());

  final GetPrayerTimesRange _getRange;
  final GetCalculationSettings _getSettings;
  final Clock _clock;

  Future<void> load({
    required double latitude,
    required double longitude,
    required String timeZoneId,
    DateTime? month,
  }) async {
    final target = month ?? _startOfMonth(_clock.today());

    emit(
      state.copyWith(
        status: MonthlyScheduleStatus.loading,
        month: target,
        today: _clock.today(),
        clearFailure: true,
      ),
    );

    final settingsResult = await _getSettings(const NoParams());
    // Defaults still produce a correct Kemenag table, so a preferences read
    // failure must not leave the screen empty.
    final settings = settingsResult.getOrElse(
      () => const CalculationSettings(),
    );

    final result = await _getRange(
      PrayerTimesRangeParams(
        base: PrayerTimesParams(
          latitude: latitude,
          longitude: longitude,
          timeZoneId: timeZoneId,
          settings: settings,
        ),
        from: target,
        to: _endOfMonth(target),
      ),
    );

    emit(
      result.fold(
        (failure) => state.copyWith(
          status: MonthlyScheduleStatus.failure,
          failure: failure,
        ),
        (days) =>
            state.copyWith(status: MonthlyScheduleStatus.success, days: days),
      ),
    );
  }

  static DateTime _startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  /// Day zero of the next month is the last day of this one, which avoids
  /// hard-coding month lengths and leap years.
  static DateTime _endOfMonth(DateTime month) =>
      DateTime(month.year, month.month + 1, 0);
}
