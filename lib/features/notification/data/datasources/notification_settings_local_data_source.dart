import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/notification_sound.dart';
import '../../domain/entities/prayer_notification_pref.dart';

abstract class NotificationSettingsLocalDataSource {
  NotificationSettings read();
  Future<void> write(NotificationSettings settings);
}

@LazySingleton(as: NotificationSettingsLocalDataSource)
class NotificationSettingsLocalDataSourceImpl
    implements NotificationSettingsLocalDataSource {
  NotificationSettingsLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'notification.settings';

  @override
  NotificationSettings read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const NotificationSettings();

    try {
      return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      // A corrupt blob must not silently disable every reminder: fall back
      // to the defaults, which have notifications on.
      return const NotificationSettings();
    }
  }

  @override
  Future<void> write(NotificationSettings settings) async {
    final ok = await _prefs.setString(_key, jsonEncode(_toJson(settings)));
    if (!ok) {
      throw const CacheException(
        message: 'Gagal menyimpan pengaturan notifikasi',
      );
    }
  }

  static Map<String, dynamic> _toJson(NotificationSettings s) => {
    'master_enabled': s.masterEnabled,
    'full_adhan_enabled': s.fullAdhanEnabled,
    'prefs': {
      for (final entry in s.prefs.entries)
        entry.key.name: {
          'enabled': entry.value.enabled,
          'sound': entry.value.sound.storageKey,
          'pre_reminder_minutes': entry.value.preReminderMinutes,
          'vibrate': entry.value.vibrate,
        },
    },
    'fajr_alarm': {
      'enabled': s.fajrAlarm.enabled,
      'minutes_before_fajr': s.fajrAlarm.minutesBeforeFajr,
      'snooze_enabled': s.fajrAlarm.snoozeEnabled,
      'snooze_minutes': s.fajrAlarm.snoozeMinutes,
    },
  };

  static NotificationSettings _fromJson(Map<String, dynamic> json) {
    final rawPrefs = (json['prefs'] as Map?)?.cast<String, dynamic>() ?? {};
    final prefs = <PrayerSlot, PrayerNotificationPref>{};

    for (final entry in rawPrefs.entries) {
      final slot = PrayerSlot.values
          .where((s) => s.name == entry.key)
          .firstOrNull;
      final value = entry.value;
      if (slot == null || value is! Map) continue;

      prefs[slot] = PrayerNotificationPref(
        slot: slot,
        enabled: value['enabled'] as bool? ?? true,
        sound: NotificationSound.fromStorageKey(value['sound'] as String?),
        preReminderMinutes: value['pre_reminder_minutes'] as int? ?? 0,
        vibrate: value['vibrate'] as bool? ?? true,
      );
    }

    final rawAlarm =
        (json['fajr_alarm'] as Map?)?.cast<String, dynamic>() ?? {};

    return NotificationSettings(
      masterEnabled: json['master_enabled'] as bool? ?? true,
      fullAdhanEnabled: json['full_adhan_enabled'] as bool? ?? true,
      prefs: prefs,
      fajrAlarm: FajrAlarmPref(
        enabled: rawAlarm['enabled'] as bool? ?? false,
        minutesBeforeFajr: rawAlarm['minutes_before_fajr'] as int? ?? 30,
        snoozeEnabled: rawAlarm['snooze_enabled'] as bool? ?? true,
        snoozeMinutes: rawAlarm['snooze_minutes'] as int? ?? 5,
      ),
    );
  }
}
