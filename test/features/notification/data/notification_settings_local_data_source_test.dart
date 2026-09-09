import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/features/notification/data/datasources/notification_settings_local_data_source.dart';
import 'package:tanbih/features/notification/domain/entities/notification_sound.dart';
import 'package:tanbih/features/notification/domain/entities/prayer_notification_pref.dart';

void main() {
  late SharedPreferences prefs;
  late NotificationSettingsLocalDataSourceImpl dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = NotificationSettingsLocalDataSourceImpl(prefs);
  });

  test('defaults have notifications on', () {
    final settings = dataSource.read();
    expect(settings.masterEnabled, isTrue);
    expect(settings.isEnabledFor(PrayerSlot.maghrib), isTrue);
    expect(settings.fajrAlarm.enabled, isFalse);
  });

  test('round-trips per-prayer preferences and the alarm', () async {
    final original =
        const NotificationSettings(
          fajrAlarm: FajrAlarmPref(enabled: true, minutesBeforeFajr: 45),
        ).withPref(
          const PrayerNotificationPref(
            slot: PrayerSlot.asr,
            enabled: false,
            sound: NotificationSound.silent,
            preReminderMinutes: 15,
            vibrate: false,
          ),
        );

    await dataSource.write(original);

    expect(dataSource.read(), original);
  });

  test('a corrupt blob falls back to defaults rather than silence', () async {
    // Silently disabling every reminder would be the worst possible
    // recovery for a reminder app.
    await prefs.setString('notification.settings', '}{not json');

    expect(dataSource.read().masterEnabled, isTrue);
  });

  test('an unknown slot in stored prefs is dropped', () async {
    await prefs.setString(
      'notification.settings',
      '{"prefs":{"asr":{"enabled":false},"tahajud":{"enabled":false}}}',
    );

    final settings = dataSource.read();
    expect(settings.prefs.keys, [PrayerSlot.asr]);
  });

  test('an unknown sound key falls back to the default tone', () async {
    await prefs.setString(
      'notification.settings',
      '{"prefs":{"isha":{"sound":"gamelan"}}}',
    );

    expect(
      dataSource.read().prefFor(PrayerSlot.isha).sound,
      NotificationSound.defaultTone,
    );
  });

  group('channel ids', () {
    test('encode the sound, because a channel sound cannot be changed', () {
      expect(
        NotificationSound.silent.channelId,
        isNot(NotificationSound.defaultTone.channelId),
      );
    });

    test('carry a version, so a replaced audio file gets a new channel', () {
      expect(
        NotificationSound.adhanShort.channelId,
        endsWith('_v${NotificationSound.channelVersion}'),
      );
    });
  });

  group('isEnabledFor', () {
    test('the master switch overrides per-prayer settings', () {
      const settings = NotificationSettings(masterEnabled: false);
      expect(settings.isEnabledFor(PrayerSlot.fajr), isFalse);
    });

    test('informational rows never notify', () {
      const settings = NotificationSettings();
      expect(settings.isEnabledFor(PrayerSlot.imsak), isFalse);
      expect(settings.isEnabledFor(PrayerSlot.sunrise), isFalse);
    });
  });
}
