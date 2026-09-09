import 'package:equatable/equatable.dart';

import '../../../../core/enums/prayer_slot.dart';
import 'notification_sound.dart';

/// How one prayer notifies.
class PrayerNotificationPref extends Equatable {
  const PrayerNotificationPref({
    required this.slot,
    this.enabled = true,
    this.sound = NotificationSound.defaultTone,
    this.preReminderMinutes = 0,
    this.vibrate = true,
  });

  final PrayerSlot slot;
  final bool enabled;
  final NotificationSound sound;

  /// Optional heads-up before the prayer. Zero means off.
  final int preReminderMinutes;

  final bool vibrate;

  bool get hasPreReminder => preReminderMinutes > 0;

  PrayerNotificationPref copyWith({
    bool? enabled,
    NotificationSound? sound,
    int? preReminderMinutes,
    bool? vibrate,
  }) {
    return PrayerNotificationPref(
      slot: slot,
      enabled: enabled ?? this.enabled,
      sound: sound ?? this.sound,
      preReminderMinutes: preReminderMinutes ?? this.preReminderMinutes,
      vibrate: vibrate ?? this.vibrate,
    );
  }

  @override
  List<Object?> get props => [
    slot,
    enabled,
    sound,
    preReminderMinutes,
    vibrate,
  ];
}

/// The wake-up alarm for sahoor or Fajr.
///
/// Separate from the prayer notification because it is an alarm: it fires
/// before Fajr, it is meant to wake someone, and it can be snoozed.
class FajrAlarmPref extends Equatable {
  const FajrAlarmPref({
    this.enabled = false,
    this.minutesBeforeFajr = 30,
    this.snoozeEnabled = true,
    this.snoozeMinutes = 5,
  });

  final bool enabled;
  final int minutesBeforeFajr;
  final bool snoozeEnabled;
  final int snoozeMinutes;

  FajrAlarmPref copyWith({
    bool? enabled,
    int? minutesBeforeFajr,
    bool? snoozeEnabled,
    int? snoozeMinutes,
  }) {
    return FajrAlarmPref(
      enabled: enabled ?? this.enabled,
      minutesBeforeFajr: minutesBeforeFajr ?? this.minutesBeforeFajr,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    );
  }

  @override
  List<Object?> get props => [
    enabled,
    minutesBeforeFajr,
    snoozeEnabled,
    snoozeMinutes,
  ];
}

/// All notification preferences together.
class NotificationSettings extends Equatable {
  const NotificationSettings({
    this.masterEnabled = true,
    this.prefs = const {},
    this.fajrAlarm = const FajrAlarmPref(),
  });

  /// Master switch. Off means nothing is scheduled at all, whatever the
  /// per-prayer settings say.
  final bool masterEnabled;

  final Map<PrayerSlot, PrayerNotificationPref> prefs;
  final FajrAlarmPref fajrAlarm;

  /// Slots that can notify. Imsak and sunrise are informational.
  static const List<PrayerSlot> notifiable = [
    PrayerSlot.fajr,
    PrayerSlot.dhuhr,
    PrayerSlot.jumuah,
    PrayerSlot.asr,
    PrayerSlot.maghrib,
    PrayerSlot.isha,
  ];

  PrayerNotificationPref prefFor(PrayerSlot slot) =>
      prefs[slot] ?? PrayerNotificationPref(slot: slot);

  bool isEnabledFor(PrayerSlot slot) =>
      masterEnabled && prefFor(slot).enabled && slot.isPrayer;

  NotificationSettings copyWith({
    bool? masterEnabled,
    Map<PrayerSlot, PrayerNotificationPref>? prefs,
    FajrAlarmPref? fajrAlarm,
  }) {
    return NotificationSettings(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      prefs: prefs ?? this.prefs,
      fajrAlarm: fajrAlarm ?? this.fajrAlarm,
    );
  }

  /// Replaces one prayer's preference.
  NotificationSettings withPref(PrayerNotificationPref pref) {
    final next = Map<PrayerSlot, PrayerNotificationPref>.from(prefs);
    next[pref.slot] = pref;
    return copyWith(prefs: next);
  }

  @override
  List<Object?> get props => [masterEnabled, prefs, fajrAlarm];
}
