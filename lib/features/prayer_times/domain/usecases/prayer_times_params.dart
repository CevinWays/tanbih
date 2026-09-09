import 'package:equatable/equatable.dart';

import '../entities/calculation_settings.dart';

/// Where and how to compute — shared by every prayer-time use case.
///
/// The time zone travels with the coordinates rather than being read from
/// the device, so a phone set to the wrong zone (or a city picked manually in
/// another zone) cannot shift the schedule.
class PrayerTimesParams extends Equatable {
  const PrayerTimesParams({
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
    required this.settings,
  });

  final double latitude;
  final double longitude;
  final String timeZoneId;
  final CalculationSettings settings;

  @override
  List<Object?> get props => [latitude, longitude, timeZoneId, settings];
}

/// [PrayerTimesParams] plus a specific date.
class PrayerTimesForDateParams extends Equatable {
  const PrayerTimesForDateParams({required this.base, required this.date});

  final PrayerTimesParams base;
  final DateTime date;

  @override
  List<Object?> get props => [base, date];
}

/// [PrayerTimesParams] plus an inclusive date range.
class PrayerTimesRangeParams extends Equatable {
  const PrayerTimesRangeParams({
    required this.base,
    required this.from,
    required this.to,
  });

  final PrayerTimesParams base;
  final DateTime from;
  final DateTime to;

  @override
  List<Object?> get props => [base, from, to];
}
