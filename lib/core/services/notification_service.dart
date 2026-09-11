import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/notification/domain/entities/notification_sound.dart';
import '../enums/prayer_slot.dart';
import '../../features/notification/domain/entities/scheduled_notification.dart';

/// Thin wrapper over `flutter_local_notifications`.
///
/// The only file that talks to the plugin. Everything above it deals in
/// [ScheduledNotification] values, which keeps the scheduling rules testable
/// without a platform channel.
abstract class NotificationService {
  Future<void> initialize();

  Future<bool> requestPermission();
  Future<bool> hasPermission();

  /// Android 12+ gates exact alarms, and Android 14 revokes them by default.
  /// Without them, reminders still arrive — just late, which for a prayer
  /// reminder is close to useless, so the UI has to be able to ask.
  Future<bool> canScheduleExactAlarms();
  Future<void> openExactAlarmSettings();

  /// Replaces the pending set with [notifications].
  ///
  /// Deliberately cancel-then-place rather than a diff: the whole window is
  /// cheap to rebuild, and a diff that goes wrong leaves a stale reminder
  /// firing at the wrong time.
  Future<void> replaceAll(
    List<ScheduledNotification> notifications, {
    required String Function(ScheduledNotification) titleOf,
    required String Function(ScheduledNotification) bodyOf,
  });

  Future<void> cancelAll();

  Future<int> pendingCount();

  /// Posts immediately, through the channel for [sound].
  ///
  /// The sound is passed in rather than fixed so a test notification plays
  /// what the user actually configured — testing the default tone while the
  /// user has chosen the adhan would prove nothing about their setup.
  Future<void> showNow({
    required String title,
    required String body,
    required NotificationSound sound,
  });
}

@LazySingleton(as: NotificationService)
class NotificationServiceImpl implements NotificationService {
  NotificationServiceImpl(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await _createChannels();
    _initialized = true;
  }

  /// One channel per sound.
  ///
  /// A channel's sound cannot be changed after creation, so the sound is
  /// baked into the channel id. Replacing a bundled audio file means bumping
  /// [NotificationSound.channelVersion], not editing a channel.
  Future<void> _createChannels() async {
    final android = _android;
    if (android == null) return;

    for (final sound in NotificationSound.values) {
      final resource = sound.rawResource;

      await android.createNotificationChannel(
        AndroidNotificationChannel(
          sound.channelId,
          _channelName(sound),
          description: _channelDescription(sound),
          importance: Importance.max,
          playSound: sound != NotificationSound.silent,
          sound: resource == null
              ? null
              : RawResourceAndroidNotificationSound(resource),
        ),
      );
    }
  }

  String _channelName(NotificationSound sound) => switch (sound) {
    NotificationSound.silent => 'Prayer reminders (silent)',
    NotificationSound.defaultTone => 'Prayer reminders',
    NotificationSound.adhanShort => 'Prayer reminders (adhan)',
  };

  String _channelDescription(NotificationSound sound) => switch (sound) {
    NotificationSound.silent =>
      'Prayer time reminders with no sound. Used when the full adhan plays '
          'separately.',
    NotificationSound.defaultTone =>
      'Prayer time reminders using the device notification sound.',
    NotificationSound.adhanShort =>
      'Prayer time reminders using a short adhan clip.',
  };

  @override
  Future<bool> requestPermission() async {
    final android = _android;
    if (android == null) return true;
    return await android.requestNotificationsPermission() ?? false;
  }

  @override
  Future<bool> hasPermission() async {
    final android = _android;
    if (android == null) return true;
    return await android.areNotificationsEnabled() ?? false;
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final android = _android;
    if (android == null) return false;
    return await android.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<void> openExactAlarmSettings() async {
    await _android?.requestExactAlarmsPermission();
  }

  @override
  Future<void> replaceAll(
    List<ScheduledNotification> notifications, {
    required String Function(ScheduledNotification) titleOf,
    required String Function(ScheduledNotification) bodyOf,
  }) async {
    await initialize();
    await cancelAll();

    // Without exact alarms Android may batch delivery by many minutes. Still
    // schedule — a late reminder beats none — but drop to the inexact mode
    // the OS will actually honour.
    final exact = await canScheduleExactAlarms();
    final mode = exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (final notification in notifications) {
      await _plugin.zonedSchedule(
        id: notification.id,
        title: titleOf(notification),
        body: bodyOf(notification),
        scheduledDate: _toTz(notification.at),
        notificationDetails: _detailsFor(notification),
        androidScheduleMode: mode,
        payload: '${notification.slot.name}:${notification.kind.name}',
      );
    }
  }

  NotificationDetails _detailsFor(ScheduledNotification notification) {
    final sound = notification.sound;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        sound.channelId,
        _channelName(sound),
        channelDescription: _channelDescription(sound),
        importance: Importance.max,
        priority: Priority.high,
        playSound: sound != NotificationSound.silent,
        enableVibration: notification.vibrate,
        category: notification.kind == ScheduledKind.fajrAlarm
            ? AndroidNotificationCategory.alarm
            : AndroidNotificationCategory.reminder,
        // The alarm is meant to wake someone, so it takes over the screen.
        fullScreenIntent: notification.kind == ScheduledKind.fajrAlarm,
      ),
    );
  }

  /// Anchors the instant in the zone the schedule was computed for.
  ///
  /// Prayer times already arrive as `TZDateTime`; anything else is
  /// interpreted in the device zone as a last resort.
  tz.TZDateTime _toTz(DateTime at) =>
      at is tz.TZDateTime ? at : tz.TZDateTime.from(at, tz.local);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<int> pendingCount() async =>
      (await _plugin.pendingNotificationRequests()).length;

  @override
  Future<void> showNow({
    required String title,
    required String body,
    required NotificationSound sound,
  }) async {
    await initialize();
    await _plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: _detailsFor(
        ScheduledNotification(
          id: 0,
          // A test notification is not tied to a real prayer; Dhuhr simply
          // gives the details builder a valid slot to work with.
          slot: PrayerSlot.dhuhr,
          kind: ScheduledKind.prayer,
          at: DateTime.now(),
          sound: sound,
          vibrate: true,
        ),
      ),
    );
  }
}
