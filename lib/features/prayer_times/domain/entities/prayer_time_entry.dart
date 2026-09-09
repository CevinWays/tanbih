import 'package:equatable/equatable.dart';

import '../../../../core/enums/prayer_slot.dart';

/// One row of the daily schedule.
class PrayerTimeEntry extends Equatable {
  const PrayerTimeEntry({required this.slot, required this.time});

  final PrayerSlot slot;
  final DateTime time;

  bool get isPrayer => slot.isPrayer;

  @override
  List<Object?> get props => [slot, time];

  @override
  String toString() => '${slot.name} @ $time';
}
