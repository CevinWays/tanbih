import 'package:equatable/equatable.dart';

import '../../../../core/enums/prayer_slot.dart';
import 'notification_sound.dart';

/// What kind of reminder an entry is.
enum ScheduledKind {
  /// At the prayer time itself.
  prayer,

  /// A configurable number of minutes before it.
  preReminder,

  /// The wake-up alarm before Fajr.
  fajrAlarm;

  /// Offset added to the base id so the three kinds never collide.
  int get idOffset => switch (this) {
    ScheduledKind.prayer => 0,
    ScheduledKind.preReminder => 10,
    ScheduledKind.fajrAlarm => 19,
  };
}

/// One notification the scheduler intends to place.
///
/// Ids are derived, never random: cancelling a specific reminder — or
/// replacing a whole day — has to be exact, and a random id cannot be
/// recomputed after a restart.
class ScheduledNotification extends Equatable {
  const ScheduledNotification({
    required this.id,
    required this.slot,
    required this.kind,
    required this.at,
    required this.sound,
    required this.vibrate,
    this.leadMinutes = 0,
  });

  /// Builds the entry with its deterministic id.
  factory ScheduledNotification.forSlot({
    required PrayerSlot slot,
    required ScheduledKind kind,
    required DateTime at,
    required DateTime day,
    required NotificationSound sound,
    required bool vibrate,
    int leadMinutes = 0,
  }) {
    return ScheduledNotification(
      id: idFor(day: day, slot: slot, kind: kind),
      slot: slot,
      kind: kind,
      at: at,
      sound: sound,
      vibrate: vibrate,
      leadMinutes: leadMinutes,
    );
  }

  final int id;
  final PrayerSlot slot;
  final ScheduledKind kind;
  final DateTime at;
  final NotificationSound sound;
  final bool vibrate;

  /// How far ahead of the prayer this fires. Zero for the prayer itself; the
  /// copy for a pre-reminder needs it to say how much time is left.
  final int leadMinutes;

  /// Slots reserved per day. Twenty leaves room for each slot's prayer entry
  /// (0-9), its pre-reminder (10-18), and the Fajr alarm (19).
  static const int slotsPerDay = 20;

  /// Days before the id space wraps. A thousand days is far beyond the
  /// seven-day scheduling window, so a live id can never be reused.
  static const int dayCycle = 1000;

  /// `(daysSinceEpoch % 1000) * 20 + slotIndex + kindOffset`.
  static int idFor({
    required DateTime day,
    required PrayerSlot slot,
    required ScheduledKind kind,
  }) {
    final days = DateTime(
      day.year,
      day.month,
      day.day,
    ).difference(DateTime(1970)).inDays;
    return (days % dayCycle) * slotsPerDay + slot.slotIndex + kind.idOffset;
  }

  @override
  List<Object?> get props => [id, slot, kind, at, sound, vibrate, leadMinutes];
}
