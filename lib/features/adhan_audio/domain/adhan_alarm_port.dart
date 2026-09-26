import '../../../core/enums/prayer_slot.dart';
import 'adhan_variant.dart';

/// One full-adhan playback the native layer should arm.
class ScheduledAdhan {
  ScheduledAdhan({
    required this.id,
    required this.slot,
    required this.at,
    required this.label,
  }) : variant = AdhanVariant.forSlot(slot);

  final int id;
  final PrayerSlot slot;
  final DateTime at;

  /// Shown on the playback notification, already localized.
  final String label;

  /// Fajr takes a different recording from the rest — see [AdhanVariant].
  final AdhanVariant variant;
}

/// The app's side of the native adhan alarm.
///
/// Full playback lives in Kotlin because it has to run from an AlarmManager
/// broadcast long after the Dart isolate is gone. This is the only seam
/// between the two.
abstract class AdhanAlarmPort {
  /// Replaces every armed adhan with [alarms].
  Future<void> replaceAll(List<ScheduledAdhan> alarms);

  Future<void> cancelAll();

  /// Whether the OS will deliver these punctually.
  Future<bool> canScheduleExact();

  /// Plays immediately, through the same path a real prayer uses — so a
  /// preview proves the real thing works, not a parallel code path.
  Future<void> playNow({required String label, String? body});

  Future<void> stop();

  /// Arms a real alarm [seconds] from now, through the production path.
  ///
  /// Debug builds only. Verifying that an alarm reaches the player with the
  /// app in the background otherwise means waiting for an actual prayer
  /// time, and this is exactly the path an aggressive OEM breaks.
  Future<void> scheduleTestAlarm({required int seconds, required String label});
}
