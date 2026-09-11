import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prayer_notification_pref.dart';
import '../../../adhan_audio/domain/adhan_alarm_port.dart';
import '../../domain/repositories/notification_repository.dart';

enum NotificationSettingsStatus { initial, loading, success, failure }

class NotificationSettingsState extends Equatable {
  const NotificationSettingsState({
    this.status = NotificationSettingsStatus.initial,
    this.settings = const NotificationSettings(),
    this.hasPermission = false,
    this.canScheduleExactAlarms = true,
    this.failure,
  });

  final NotificationSettingsStatus status;
  final NotificationSettings settings;

  /// Runtime notification permission (Android 13+). Without it nothing the
  /// user configures here will ever be delivered.
  final bool hasPermission;

  /// Exact alarms. Without them reminders still arrive, but batched — late
  /// enough to matter for a prayer time.
  final bool canScheduleExactAlarms;

  final Failure? failure;

  /// The two conditions worth warning about on screen.
  bool get needsAttention => !hasPermission || !canScheduleExactAlarms;

  NotificationSettingsState copyWith({
    NotificationSettingsStatus? status,
    NotificationSettings? settings,
    bool? hasPermission,
    bool? canScheduleExactAlarms,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return NotificationSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      hasPermission: hasPermission ?? this.hasPermission,
      canScheduleExactAlarms:
          canScheduleExactAlarms ?? this.canScheduleExactAlarms,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    settings,
    hasPermission,
    canScheduleExactAlarms,
    failure,
  ];
}

/// Notification preferences, plus the OS permissions they depend on.
///
/// A singleton for the same reason the calculation settings are: the
/// scheduler listens to this, so there must be exactly one of it.
@lazySingleton
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit(this._repository, this._adhanAlarms)
    : super(const NotificationSettingsState());

  final NotificationRepository _repository;
  final AdhanAlarmPort _adhanAlarms;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationSettingsStatus.loading));

    final settings = await _repository.getSettings();
    final permission = await _repository.hasPermission();
    final exact = await _repository.canScheduleExactAlarms();

    emit(
      settings.fold(
        (failure) => state.copyWith(
          status: NotificationSettingsStatus.failure,
          failure: failure,
        ),
        (value) => state.copyWith(
          status: NotificationSettingsStatus.success,
          settings: value,
          hasPermission: permission.getOrElse(() => false),
          canScheduleExactAlarms: exact.getOrElse(() => false),
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> requestPermission() async {
    final granted = await _repository.requestPermission();
    emit(state.copyWith(hasPermission: granted.getOrElse(() => false)));
  }

  Future<void> openExactAlarmSettings() async {
    await _repository.openExactAlarmSettings();
    // The user leaves the app to change this, so re-check rather than
    // assuming the trip succeeded.
    final exact = await _repository.canScheduleExactAlarms();
    emit(state.copyWith(canScheduleExactAlarms: exact.getOrElse(() => false)));
  }

  Future<void> setFullAdhanEnabled(bool enabled) =>
      _update(state.settings.copyWith(fullAdhanEnabled: enabled));

  /// Plays through the native service, the same path a real prayer takes, so
  /// a preview that works proves the real thing works.
  Future<void> previewFullAdhan({required String label, String? body}) =>
      _adhanAlarms.playNow(label: label, body: body);

  Future<void> stopFullAdhan() => _adhanAlarms.stop();

  /// Debug builds only — see [AdhanAlarmPort.scheduleTestAlarm].
  ///
  /// Replaces the armed window, so the schedule is rebuilt afterwards by the
  /// usual sync when settings or location next change.
  Future<void> scheduleTestAdhan({required String label}) =>
      _adhanAlarms.scheduleTestAlarm(seconds: 20, label: label);

  Future<void> setMasterEnabled(bool enabled) =>
      _update(state.settings.copyWith(masterEnabled: enabled));

  Future<void> setPref(PrayerNotificationPref pref) =>
      _update(state.settings.withPref(pref));

  Future<void> togglePrayer(PrayerSlot slot, bool enabled) =>
      setPref(state.settings.prefFor(slot).copyWith(enabled: enabled));

  Future<void> setFajrAlarm(FajrAlarmPref alarm) =>
      _update(state.settings.copyWith(fajrAlarm: alarm));

  /// Fires a sample using the sound configured for [slot], so what the user
  /// hears is what the real reminder will play.
  Future<void> sendTestNotification({
    PrayerSlot slot = PrayerSlot.dhuhr,
  }) async {
    final result = await _repository.sendTestNotification(
      state.settings.prefFor(slot).sound,
    );
    result.fold((failure) => emit(state.copyWith(failure: failure)), (_) {});
  }

  /// Applies first, persists after — the switch should move under the user's
  /// finger, and a storage failure must not undo their choice.
  Future<void> _update(NotificationSettings settings) async {
    emit(
      state.copyWith(
        status: NotificationSettingsStatus.success,
        settings: settings,
        clearFailure: true,
      ),
    );

    final result = await _repository.saveSettings(settings);
    result.fold((failure) => emit(state.copyWith(failure: failure)), (_) {});
  }
}
