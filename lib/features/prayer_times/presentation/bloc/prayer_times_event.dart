import 'package:equatable/equatable.dart';

import '../../domain/entities/calculation_settings.dart';

sealed class PrayerTimesEvent extends Equatable {
  const PrayerTimesEvent();

  @override
  List<Object?> get props => [];
}

/// Load the schedule for the currently selected date.
final class PrayerTimesLoadRequested extends PrayerTimesEvent {
  const PrayerTimesLoadRequested({
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
  });

  final double latitude;
  final double longitude;
  final String timeZoneId;

  @override
  List<Object?> get props => [latitude, longitude, timeZoneId];
}

/// Browse to another day. Keeps the current location.
final class PrayerTimesDateChanged extends PrayerTimesEvent {
  const PrayerTimesDateChanged(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

/// Jump back to today.
final class PrayerTimesTodayRequested extends PrayerTimesEvent {
  const PrayerTimesTodayRequested();
}

/// Recalculate after the user changed a calculation option.
final class PrayerTimesSettingsChanged extends PrayerTimesEvent {
  const PrayerTimesSettingsChanged(this.settings);

  final CalculationSettings settings;

  @override
  List<Object?> get props => [settings];
}
