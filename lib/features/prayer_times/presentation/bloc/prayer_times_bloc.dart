import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/calculation_settings.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/usecases/get_calculation_settings.dart';
import '../../domain/usecases/get_prayer_times_range.dart';
import '../../domain/usecases/prayer_times_params.dart';
import '../../domain/usecases/save_calculation_settings.dart';
import '../../../../core/error/failures.dart';
import 'prayer_times_event.dart';
import 'prayer_times_state.dart';

/// Owns the displayed schedule.
///
/// Per-second countdown deliberately lives in `NextPrayerCountdownCubit`
/// instead: emitting this whole state every second would rebuild the entire
/// prayer list sixty times a minute.
@injectable
class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  PrayerTimesBloc(
    this._getPrayerTimesRange,
    this._getCalculationSettings,
    this._saveCalculationSettings,
    this._clock,
  ) : super(const PrayerTimesState()) {
    on<PrayerTimesLoadRequested>(_onLoadRequested);
    on<PrayerTimesDateChanged>(_onDateChanged);
    on<PrayerTimesTodayRequested>(_onTodayRequested);
    on<PrayerTimesSettingsChanged>(_onSettingsChanged);
  }

  final GetPrayerTimesRange _getPrayerTimesRange;
  final GetCalculationSettings _getCalculationSettings;
  final SaveCalculationSettings _saveCalculationSettings;
  final Clock _clock;

  Future<void> _onLoadRequested(
    PrayerTimesLoadRequested event,
    Emitter<PrayerTimesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PrayerTimesStatus.loading,
        latitude: event.latitude,
        longitude: event.longitude,
        timeZoneId: event.timeZoneId,
        clearFailure: true,
      ),
    );

    // Stored settings are read on every load rather than cached in the bloc,
    // so a change made in the settings screens cannot go stale here.
    final settingsResult = await _getCalculationSettings(const NoParams());

    final settings = settingsResult.getOrElse(() => state.settings);
    final failedToRead = settingsResult.isLeft();

    await _emitTimes(
      emit,
      settings: settings,
      date: state.selectedDate ?? _clock.today(),
      latitude: event.latitude,
      longitude: event.longitude,
      timeZoneId: event.timeZoneId,
      // A settings read failure is not fatal: defaults still produce a
      // correct Kemenag schedule, which matters more than the preference.
      settingsReadFailed: failedToRead,
    );
  }

  Future<void> _onDateChanged(
    PrayerTimesDateChanged event,
    Emitter<PrayerTimesState> emit,
  ) async {
    if (!state.hasLocation) {
      emit(state.copyWith(selectedDate: event.date));
      return;
    }

    emit(
      state.copyWith(
        status: PrayerTimesStatus.loading,
        selectedDate: event.date,
        clearFailure: true,
      ),
    );

    await _emitTimes(
      emit,
      settings: state.settings,
      date: event.date,
      latitude: state.latitude!,
      longitude: state.longitude!,
      timeZoneId: state.timeZoneId!,
    );
  }

  Future<void> _onTodayRequested(
    PrayerTimesTodayRequested event,
    Emitter<PrayerTimesState> emit,
  ) => _onDateChanged(PrayerTimesDateChanged(_clock.today()), emit);

  Future<void> _onSettingsChanged(
    PrayerTimesSettingsChanged event,
    Emitter<PrayerTimesState> emit,
  ) async {
    final saved = await _saveCalculationSettings(event.settings);

    // Even if persisting failed, the new settings are applied to what the
    // user is looking at — silently showing the old schedule would be worse.
    final failure = saved.fold((f) => f, (_) => null);

    if (!state.hasLocation) {
      emit(state.copyWith(settings: event.settings, failure: failure));
      return;
    }

    emit(
      state.copyWith(
        status: PrayerTimesStatus.loading,
        settings: event.settings,
        clearFailure: true,
      ),
    );

    await _emitTimes(
      emit,
      settings: event.settings,
      date: state.selectedDate ?? _clock.today(),
      latitude: state.latitude!,
      longitude: state.longitude!,
      timeZoneId: state.timeZoneId!,
      carriedFailure: failure,
    );
  }

  Future<void> _emitTimes(
    Emitter<PrayerTimesState> emit, {
    required CalculationSettings settings,
    required DateTime date,
    required double latitude,
    required double longitude,
    required String timeZoneId,
    bool settingsReadFailed = false,
    Failure? carriedFailure,
  }) async {
    // Three days, not one. The countdown has to look past both ends of the
    // day — to tomorrow's Fajr after Isha, and back to yesterday's Isha for
    // the progress ring — while the header keeps showing today.
    final day = DateTime(date.year, date.month, date.day);
    final result = await _getPrayerTimesRange(
      PrayerTimesRangeParams(
        base: PrayerTimesParams(
          latitude: latitude,
          longitude: longitude,
          timeZoneId: timeZoneId,
          settings: settings,
        ),
        from: day.subtract(const Duration(days: 1)),
        to: day.add(const Duration(days: 1)),
      ),
    );

    emit(
      result.fold(
        (failure) => state.copyWith(
          status: PrayerTimesStatus.failure,
          settings: settings,
          selectedDate: date,
          failure: failure,
        ),
        (window) {
          final selected = _dayIn(window, day);
          if (selected == null) {
            return state.copyWith(
              status: PrayerTimesStatus.failure,
              settings: settings,
              selectedDate: date,
              failure: const CalculationFailure(),
            );
          }

          return state.copyWith(
            status: PrayerTimesStatus.success,
            times: selected,
            previousTimes: _dayIn(
              window,
              day.subtract(const Duration(days: 1)),
            ),
            nextTimes: _dayIn(window, day.add(const Duration(days: 1))),
            settings: settings,
            selectedDate: date,
            failure: carriedFailure,
            clearFailure: carriedFailure == null && !settingsReadFailed,
          );
        },
      ),
    );
  }

  /// The schedule for [day], matched on the calendar date rather than on
  /// position, so a short or reordered range cannot silently mislabel a day.
  static DailyPrayerTimes? _dayIn(List<DailyPrayerTimes> window, DateTime day) {
    for (final times in window) {
      if (times.date.year == day.year &&
          times.date.month == day.month &&
          times.date.day == day.day) {
        return times;
      }
    }
    return null;
  }
}
