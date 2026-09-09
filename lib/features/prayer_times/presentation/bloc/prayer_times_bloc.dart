import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/clock.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/calculation_settings.dart';
import '../../domain/usecases/get_calculation_settings.dart';
import '../../domain/usecases/get_prayer_times_for_date.dart';
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
    this._getPrayerTimesForDate,
    this._getCalculationSettings,
    this._saveCalculationSettings,
    this._clock,
  ) : super(const PrayerTimesState()) {
    on<PrayerTimesLoadRequested>(_onLoadRequested);
    on<PrayerTimesDateChanged>(_onDateChanged);
    on<PrayerTimesTodayRequested>(_onTodayRequested);
    on<PrayerTimesSettingsChanged>(_onSettingsChanged);
  }

  final GetPrayerTimesForDate _getPrayerTimesForDate;
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
    final result = await _getPrayerTimesForDate(
      PrayerTimesForDateParams(
        base: PrayerTimesParams(
          latitude: latitude,
          longitude: longitude,
          timeZoneId: timeZoneId,
          settings: settings,
        ),
        date: date,
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
        (times) => state.copyWith(
          status: PrayerTimesStatus.success,
          times: times,
          settings: settings,
          selectedDate: date,
          failure: carriedFailure,
          clearFailure: carriedFailure == null && !settingsReadFailed,
        ),
      ),
    );
  }
}
