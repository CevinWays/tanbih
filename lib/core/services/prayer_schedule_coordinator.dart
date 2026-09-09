import 'dart:ui' show Locale;

import 'package:injectable/injectable.dart';

import '../../features/notification/domain/entities/prayer_notification_pref.dart';
import '../../features/notification/domain/entities/scheduled_notification.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/services/notification_planner.dart';
import '../../features/prayer_times/domain/entities/calculation_settings.dart';
import '../../features/prayer_times/domain/usecases/get_calculation_settings.dart';
import '../../features/prayer_times/domain/usecases/get_prayer_times_range.dart';
import '../../features/prayer_times/domain/usecases/prayer_times_params.dart';
import '../config/app_config.dart';
import '../l10n/generated/app_localizations.dart';
import '../usecases/usecase.dart';
import '../utils/prayer_slot_x.dart';
import 'app_context.dart';
import 'clock.dart';
import 'notification_service.dart';

/// Outcome of a reschedule, for logging and for the settings screen.
class ScheduleResult {
  const ScheduleResult({
    required this.scheduled,
    required this.usedExactAlarms,
  });

  const ScheduleResult.skipped() : scheduled = 0, usedExactAlarms = false;

  final int scheduled;

  /// False when the OS refused exact alarms, which means reminders will
  /// arrive late rather than on time — worth telling the user about.
  final bool usedExactAlarms;
}

/// The single writer of the notification schedule.
///
/// Blocs and widgets never touch the plugin: they change settings or
/// location and call this. One writer is what makes "cancel everything, then
/// re-place the window" safe — there is no second writer to race with.
@lazySingleton
class PrayerScheduleCoordinator {
  PrayerScheduleCoordinator(
    this._getRange,
    this._getCalculationSettings,
    this._notifications,
    this._service,
    this._clock,
    this._appContext,
  );

  final GetPrayerTimesRange _getRange;
  final GetCalculationSettings _getCalculationSettings;
  final NotificationRepository _notifications;
  final NotificationService _service;
  final Clock _clock;
  final AppContext _appContext;

  static const NotificationPlanner _planner = NotificationPlanner();

  double? _lastLatitude;
  double? _lastLongitude;

  /// Whether the schedule needs rebuilding for a new position.
  ///
  /// Prayer times move by well under a minute over a few kilometres, so a
  /// small drift is not worth cancelling and re-placing sixty alarms for.
  bool needsRescheduleFor(double latitude, double longitude) {
    final lat = _lastLatitude;
    final lng = _lastLongitude;
    if (lat == null || lng == null) return true;

    // Rough metres-per-degree at the equator; precise enough for a
    // threshold check and avoids pulling in a geodesy dependency here.
    const metresPerDegree = 111320.0;
    final dLat = (latitude - lat).abs() * metresPerDegree;
    final dLng = (longitude - lng).abs() * metresPerDegree;

    return dLat + dLng >= AppConfig.rescheduleDistanceThresholdMeters;
  }

  /// Rebuilds the whole notification window for [latitude]/[longitude].
  Future<ScheduleResult> reschedule({
    required double latitude,
    required double longitude,
    required String timeZoneId,
  }) async {
    final settingsResult = await _notifications.getSettings();
    final settings = settingsResult.getOrElse(
      () => const NotificationSettings(),
    );

    if (!settings.masterEnabled) {
      await _service.cancelAll();
      _remember(latitude, longitude);
      return const ScheduleResult.skipped();
    }

    // Nothing can be delivered without the runtime permission, and placing
    // alarms the OS will drop just wastes work.
    final permitted = (await _notifications.hasPermission()).getOrElse(
      () => false,
    );
    if (!permitted) return const ScheduleResult.skipped();

    final calculation = (await _getCalculationSettings(
      const NoParams(),
    )).getOrElse(() => const CalculationSettings());

    final today = _clock.today();
    final daysResult = await _getRange(
      PrayerTimesRangeParams(
        base: PrayerTimesParams(
          latitude: latitude,
          longitude: longitude,
          timeZoneId: timeZoneId,
          settings: calculation,
        ),
        from: today,
        to: today.add(const Duration(days: AppConfig.scheduleWindowDays - 1)),
      ),
    );

    final days = daysResult.getOrElse(() => const []);
    if (days.isEmpty) return const ScheduleResult.skipped();

    final plan = _planner.plan(
      days: days,
      settings: settings,
      now: _clock.now(),
      limit: AppConfig.maxPendingNotifications,
    );

    final l10n = await AppLocalizations.delegate.load(
      Locale(_appContext.languageCode),
    );

    await _service.replaceAll(
      plan,
      titleOf: (n) => _titleFor(n, l10n),
      bodyOf: (n) => _bodyFor(n, l10n),
    );

    _remember(latitude, longitude);

    return ScheduleResult(
      scheduled: plan.length,
      usedExactAlarms: await _service.canScheduleExactAlarms(),
    );
  }

  /// Clears everything. Used when the user turns notifications off.
  Future<void> cancelAll() => _service.cancelAll();

  void _remember(double latitude, double longitude) {
    _lastLatitude = latitude;
    _lastLongitude = longitude;
  }

  String _titleFor(ScheduledNotification n, AppLocalizations l10n) =>
      switch (n.kind) {
        ScheduledKind.prayer => n.slot.label(l10n),
        ScheduledKind.preReminder => n.slot.label(l10n),
        ScheduledKind.fajrAlarm => l10n.settingsFajrAlarm,
      };

  String _bodyFor(ScheduledNotification n, AppLocalizations l10n) =>
      switch (n.kind) {
        ScheduledKind.prayer => l10n.prayerTimeNow,
        ScheduledKind.preReminder => l10n.preReminderBody(
          n.leadMinutes,
          n.slot.label(l10n),
        ),
        ScheduledKind.fajrAlarm => l10n.settingsFajrAlarmSubtitle,
      };
}
