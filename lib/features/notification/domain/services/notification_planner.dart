import '../../../../core/enums/prayer_slot.dart';
import '../../../prayer_times/domain/entities/daily_prayer_times.dart';
import '../entities/notification_sound.dart';
import '../entities/prayer_notification_pref.dart';
import '../entities/scheduled_notification.dart';

/// Turns a run of days into the exact list of notifications to place.
///
/// Pure logic with no platform calls, so the scheduling rules — the part
/// most likely to go subtly wrong — are directly testable.
class NotificationPlanner {
  const NotificationPlanner();

  /// Hard ceiling on pending notifications.
  ///
  /// Under the 64 iOS keeps, and it bounds how much work one reschedule does
  /// on Android.
  static const int maxPending = 60;

  /// Builds the plan for [days], dropping anything already past.
  ///
  /// [now] is passed in rather than read from a clock so the cutoff is the
  /// caller's decision and the result is reproducible in tests.
  List<ScheduledNotification> plan({
    required List<DailyPrayerTimes> days,
    required NotificationSettings settings,
    required DateTime now,
    int limit = maxPending,
  }) {
    if (!settings.masterEnabled) return const [];

    final planned = <ScheduledNotification>[];

    for (final day in days) {
      for (final entry in day.entries) {
        if (!settings.isEnabledFor(entry.slot)) continue;

        final pref = settings.prefFor(entry.slot);

        if (entry.time.isAfter(now)) {
          planned.add(
            ScheduledNotification.forSlot(
              slot: entry.slot,
              kind: ScheduledKind.prayer,
              at: entry.time,
              day: day.date,
              // With full playback on, the native player carries the sound;
              // leaving the channel audible would start the 30-second clip
              // and the full recitation at the same instant.
              sound: settings.fullAdhanEnabled
                  ? NotificationSound.silent
                  : pref.sound,
              vibrate: pref.vibrate,
            ),
          );
        }

        if (pref.hasPreReminder) {
          final at = entry.time.subtract(
            Duration(minutes: pref.preReminderMinutes),
          );
          // A pre-reminder whose moment has passed is dropped even when the
          // prayer itself is still ahead: firing it late is worse than not
          // firing it.
          if (at.isAfter(now)) {
            planned.add(
              ScheduledNotification.forSlot(
                slot: entry.slot,
                kind: ScheduledKind.preReminder,
                at: at,
                day: day.date,
                sound: pref.sound,
                vibrate: pref.vibrate,
                leadMinutes: pref.preReminderMinutes,
              ),
            );
          }
        }
      }

      final alarm = _fajrAlarmFor(day, settings, now);
      if (alarm != null) planned.add(alarm);
    }

    planned.sort((a, b) => a.at.compareTo(b.at));

    // Trim the far end: the soonest reminders matter most, and the next
    // housekeeping pass extends the window again.
    return planned.length <= limit ? planned : planned.sublist(0, limit);
  }

  ScheduledNotification? _fajrAlarmFor(
    DailyPrayerTimes day,
    NotificationSettings settings,
    DateTime now,
  ) {
    final alarm = settings.fajrAlarm;
    if (!alarm.enabled) return null;

    final fajr = day.entryFor(PrayerSlot.fajr);
    if (fajr == null) return null;

    final at = fajr.time.subtract(Duration(minutes: alarm.minutesBeforeFajr));
    if (!at.isAfter(now)) return null;

    return ScheduledNotification.forSlot(
      slot: PrayerSlot.fajr,
      kind: ScheduledKind.fajrAlarm,
      at: at,
      day: day.date,
      // An alarm has to be audible even when the Fajr notification itself
      // is set to silent.
      sound: settings.prefFor(PrayerSlot.fajr).sound,
      vibrate: true,
      leadMinutes: alarm.minutesBeforeFajr,
    );
  }
}
