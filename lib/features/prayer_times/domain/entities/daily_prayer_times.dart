import 'package:equatable/equatable.dart';

import '../../../../core/enums/prayer_slot.dart';
import 'hijri_date.dart';
import 'prayer_time_entry.dart';

/// A full day's schedule, plus the derived "where are we now" answers the UI
/// and the scheduler both need.
class DailyPrayerTimes extends Equatable {
  const DailyPrayerTimes({
    required this.date,
    required this.entries,
    required this.hijriDate,
  });

  /// Midnight of the day these times belong to, in local time.
  final DateTime date;

  /// Chronologically ordered, including the informational imsak and sunrise
  /// rows. On Fridays with a configured Jumu'ah time, the dhuhr row is
  /// replaced by a jumuah row rather than duplicated.
  final List<PrayerTimeEntry> entries;

  final HijriDate hijriDate;

  /// Rows that can trigger an adhan or a notification.
  List<PrayerTimeEntry> get prayerEntries =>
      entries.where((e) => e.isPrayer).toList(growable: false);

  PrayerTimeEntry? entryFor(PrayerSlot slot) {
    for (final entry in entries) {
      if (entry.slot == slot) return entry;
    }
    return null;
  }

  /// The prayer currently in effect — the latest prayer whose time has
  /// passed. Null before Fajr, where the current prayer belongs to yesterday.
  PrayerTimeEntry? currentPrayerAt(DateTime now) {
    PrayerTimeEntry? current;
    for (final entry in prayerEntries) {
      if (!entry.time.isAfter(now)) {
        current = entry;
      } else {
        break;
      }
    }
    return current;
  }

  /// The next prayer later today, or null after Isha — the caller then looks
  /// at tomorrow's schedule. Returning null rather than wrapping keeps this
  /// entity honest about only knowing one day.
  PrayerTimeEntry? nextPrayerAt(DateTime now) {
    for (final entry in prayerEntries) {
      if (entry.time.isAfter(now)) return entry;
    }
    return null;
  }

  /// Time until the next prayer today, or null if there is none left.
  Duration? timeUntilNext(DateTime now) {
    return nextPrayerAt(now)?.time.difference(now);
  }

  @override
  List<Object?> get props => [date, entries, hijriDate];
}
