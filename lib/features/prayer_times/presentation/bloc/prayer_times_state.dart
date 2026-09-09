import 'package:equatable/equatable.dart';

import '../../../../core/enums/prayer_slot.dart';
import '../../domain/entities/calculation_settings.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/entities/prayer_time_entry.dart';
import '../../../../core/error/failures.dart';

enum PrayerTimesStatus { initial, loading, success, failure }

/// One state class with an enum status, per the project's bloc convention.
class PrayerTimesState extends Equatable {
  const PrayerTimesState({
    this.status = PrayerTimesStatus.initial,
    this.times,
    this.settings = const CalculationSettings(),
    this.selectedDate,
    this.latitude,
    this.longitude,
    this.timeZoneId,
    this.failure,
  });

  final PrayerTimesStatus status;
  final DailyPrayerTimes? times;
  final CalculationSettings settings;

  /// Day being displayed. Null until the first load resolves.
  final DateTime? selectedDate;

  /// Location the current schedule was computed from. Retained so a date
  /// change or a settings change can recompute without waiting on the
  /// location feature again.
  final double? latitude;
  final double? longitude;
  final String? timeZoneId;

  final Failure? failure;

  bool get hasLocation =>
      latitude != null && longitude != null && timeZoneId != null;

  /// Rows worth showing — includes the informational imsak and sunrise.
  List<PrayerTimeEntry> get entries => times?.entries ?? const [];

  PrayerTimeEntry? nextPrayerAt(DateTime now) => times?.nextPrayerAt(now);

  PrayerTimeEntry? currentPrayerAt(DateTime now) => times?.currentPrayerAt(now);

  PrayerTimeEntry? entryFor(PrayerSlot slot) => times?.entryFor(slot);

  PrayerTimesState copyWith({
    PrayerTimesStatus? status,
    DailyPrayerTimes? times,
    CalculationSettings? settings,
    DateTime? selectedDate,
    double? latitude,
    double? longitude,
    String? timeZoneId,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return PrayerTimesState(
      status: status ?? this.status,
      times: times ?? this.times,
      settings: settings ?? this.settings,
      selectedDate: selectedDate ?? this.selectedDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    times,
    settings,
    selectedDate,
    latitude,
    longitude,
    timeZoneId,
    failure,
  ];
}
