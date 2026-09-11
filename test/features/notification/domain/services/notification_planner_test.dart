import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/features/notification/domain/entities/notification_sound.dart';
import 'package:tanbih/features/notification/domain/entities/prayer_notification_pref.dart';
import 'package:tanbih/features/notification/domain/entities/scheduled_notification.dart';
import 'package:tanbih/features/notification/domain/services/notification_planner.dart';
import 'package:tanbih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:tanbih/features/prayer_times/domain/entities/hijri_date.dart';
import 'package:tanbih/features/prayer_times/domain/entities/prayer_time_entry.dart';

void main() {
  const planner = NotificationPlanner();
  const hijri = HijriDate(
    year: 1448,
    month: 3,
    day: 1,
    monthName: "Rabi'ul Awal",
  );

  DailyPrayerTimes dayAt(DateTime date) {
    PrayerTimeEntry at(PrayerSlot slot, int h, int m) => PrayerTimeEntry(
      slot: slot,
      time: DateTime(date.year, date.month, date.day, h, m),
    );
    return DailyPrayerTimes(
      date: DateTime(date.year, date.month, date.day),
      hijriDate: hijri,
      entries: [
        at(PrayerSlot.imsak, 4, 25),
        at(PrayerSlot.fajr, 4, 35),
        at(PrayerSlot.sunrise, 5, 47),
        at(PrayerSlot.dhuhr, 11, 54),
        at(PrayerSlot.asr, 15, 10),
        at(PrayerSlot.maghrib, 17, 55),
        at(PrayerSlot.isha, 19, 3),
      ],
    );
  }

  final week = List.generate(
    7,
    (i) => dayAt(DateTime(2026, 9, 7).add(Duration(days: i))),
  );
  final beforeDawn = DateTime(2026, 9, 7, 3);

  NotificationSettings withPreReminders(int minutes, {bool alarm = false}) {
    var settings = NotificationSettings(
      fajrAlarm: FajrAlarmPref(enabled: alarm),
    );
    for (final slot in NotificationSettings.notifiable) {
      settings = settings.withPref(
        PrayerNotificationPref(slot: slot, preReminderMinutes: minutes),
      );
    }
    return settings;
  }

  group('what gets scheduled', () {
    test('only prayers — imsak and sunrise are informational rows', () {
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings(),
        now: beforeDawn,
      );
      expect(plan.map((n) => n.slot).toSet(), {
        PrayerSlot.fajr,
        PrayerSlot.dhuhr,
        PrayerSlot.asr,
        PrayerSlot.maghrib,
        PrayerSlot.isha,
      });
    });

    test('the master switch suppresses everything', () {
      expect(
        planner.plan(
          days: week,
          settings: const NotificationSettings(masterEnabled: false),
          now: beforeDawn,
        ),
        isEmpty,
      );
    });

    test('a disabled prayer is skipped, the rest are untouched', () {
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings().withPref(
          const PrayerNotificationPref(slot: PrayerSlot.asr, enabled: false),
        ),
        now: beforeDawn,
      );
      expect(plan.map((n) => n.slot), isNot(contains(PrayerSlot.asr)));
      expect(plan.map((n) => n.slot), contains(PrayerSlot.maghrib));
    });

    test('times already past are dropped', () {
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings(),
        now: DateTime(2026, 9, 7, 16),
      );
      expect(plan.map((n) => n.slot), [PrayerSlot.maghrib, PrayerSlot.isha]);
    });

    test('results come out ordered by time', () {
      final plan = planner.plan(
        days: week,
        settings: const NotificationSettings(),
        now: beforeDawn,
      );
      for (var i = 1; i < plan.length; i++) {
        expect(plan[i].at.isBefore(plan[i - 1].at), isFalse);
      }
    });
  });

  group('pre-reminders', () {
    test('land the configured number of minutes earlier', () {
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings().withPref(
          const PrayerNotificationPref(
            slot: PrayerSlot.maghrib,
            preReminderMinutes: 15,
          ),
        ),
        now: beforeDawn,
      );
      final pre = plan.firstWhere((n) => n.kind == ScheduledKind.preReminder);
      expect(pre.slot, PrayerSlot.maghrib);
      expect(pre.at, DateTime(2026, 9, 7, 17, 40));
    });

    test('are dropped once passed, even if the prayer is still ahead', () {
      // 17:45 sits between the reminder (17:40) and Maghrib (17:55).
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings().withPref(
          const PrayerNotificationPref(
            slot: PrayerSlot.maghrib,
            preReminderMinutes: 15,
          ),
        ),
        now: DateTime(2026, 9, 7, 17, 45),
      );
      expect(plan.where((n) => n.kind == ScheduledKind.preReminder), isEmpty);
      expect(
        plan.where(
          (n) => n.slot == PrayerSlot.maghrib && n.kind == ScheduledKind.prayer,
        ),
        hasLength(1),
      );
    });

    test('zero minutes means none at all', () {
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings(),
        now: beforeDawn,
      );
      expect(plan.every((n) => n.kind == ScheduledKind.prayer), isTrue);
    });
  });

  group('Fajr alarm', () {
    test('lands before Fajr by the configured margin', () {
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings(
          fajrAlarm: FajrAlarmPref(enabled: true, minutesBeforeFajr: 45),
        ),
        now: DateTime(2026, 9, 7, 1),
      );
      final alarm = plan.firstWhere((n) => n.kind == ScheduledKind.fajrAlarm);
      expect(alarm.at, DateTime(2026, 9, 7, 3, 50));
    });

    test('stays audible when Fajr itself is silent', () {
      // Someone who silences the Fajr notification but still needs waking
      // for sahoor must not end up with a silent alarm.
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings:
            const NotificationSettings(
              fajrAlarm: FajrAlarmPref(enabled: true),
            ).withPref(
              const PrayerNotificationPref(
                slot: PrayerSlot.fajr,
                sound: NotificationSound.silent,
              ),
            ),
        now: DateTime(2026, 9, 7, 1),
      );
      final alarm = plan.firstWhere((n) => n.kind == ScheduledKind.fajrAlarm);
      expect(alarm.vibrate, isTrue);
    });

    test('is absent when disabled', () {
      final plan = planner.plan(
        days: week,
        settings: const NotificationSettings(),
        now: beforeDawn,
      );
      expect(plan.where((n) => n.kind == ScheduledKind.fajrAlarm), isEmpty);
    });
  });

  group('ids', () {
    test('are unique across a full week with every extra enabled', () {
      final plan = planner.plan(
        days: week,
        settings: withPreReminders(10, alarm: true),
        now: beforeDawn,
        limit: 1000,
      );
      final ids = plan.map((n) => n.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('are stable for a given day and slot', () {
      expect(
        ScheduledNotification.idFor(
          day: DateTime(2026, 9, 7),
          slot: PrayerSlot.asr,
          kind: ScheduledKind.prayer,
        ),
        ScheduledNotification.idFor(
          day: DateTime(2026, 9, 7, 23, 59),
          slot: PrayerSlot.asr,
          kind: ScheduledKind.prayer,
        ),
      );
    });

    test('the three kinds never collide for one slot and day', () {
      final ids = ScheduledKind.values
          .map(
            (kind) => ScheduledNotification.idFor(
              day: DateTime(2026, 9, 7),
              slot: PrayerSlot.fajr,
              kind: kind,
            ),
          )
          .toSet();
      expect(ids.length, ScheduledKind.values.length);
    });

    test('consecutive days do not overlap', () {
      expect(
        ScheduledNotification.idFor(
          day: DateTime(2026, 9, 7),
          slot: PrayerSlot.isha,
          kind: ScheduledKind.preReminder,
        ),
        isNot(
          ScheduledNotification.idFor(
            day: DateTime(2026, 9, 8),
            slot: PrayerSlot.fajr,
            kind: ScheduledKind.prayer,
          ),
        ),
      );
    });
  });

  group('full adhan playback', () {
    test('silences the visible notification so the two do not overlap', () {
      // The native player carries the recitation. Leaving the channel
      // audible would start the 30-second clip and the full adhan at the
      // same instant.
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings(),
        now: beforeDawn,
      );

      expect(
        plan
            .where((n) => n.kind == ScheduledKind.prayer)
            .map((n) => n.sound)
            .toSet(),
        {NotificationSound.silent},
      );
    });

    test('with it off, the chosen per-prayer sound is used', () {
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings(fullAdhanEnabled: false).withPref(
          const PrayerNotificationPref(
            slot: PrayerSlot.maghrib,
            sound: NotificationSound.adhanShort,
          ),
        ),
        now: beforeDawn,
      );

      expect(
        plan
            .firstWhere(
              (n) =>
                  n.slot == PrayerSlot.maghrib &&
                  n.kind == ScheduledKind.prayer,
            )
            .sound,
        NotificationSound.adhanShort,
      );
    });

    test('does not silence the pre-reminder', () {
      // The heads-up fires before the adhan, so it still needs to be heard.
      final plan = planner.plan(
        days: [dayAt(DateTime(2026, 9, 7))],
        settings: const NotificationSettings().withPref(
          const PrayerNotificationPref(
            slot: PrayerSlot.maghrib,
            preReminderMinutes: 15,
            sound: NotificationSound.defaultTone,
          ),
        ),
        now: beforeDawn,
      );

      expect(
        plan.firstWhere((n) => n.kind == ScheduledKind.preReminder).sound,
        NotificationSound.defaultTone,
      );
    });
  });

  group('the pending ceiling', () {
    test('is never exceeded', () {
      final plan = planner.plan(
        days: week,
        settings: withPreReminders(10, alarm: true),
        now: beforeDawn,
      );
      expect(plan.length, lessThanOrEqualTo(NotificationPlanner.maxPending));
    });

    test('trimming keeps the soonest reminders', () {
      final plan = planner.plan(
        days: week,
        settings: withPreReminders(10),
        now: beforeDawn,
        limit: 5,
      );
      expect(plan.length, 5);
      // Today's first reminder, not an arbitrary entry from later in the week.
      expect(plan.first.at, DateTime(2026, 9, 7, 4, 25));
    });
  });
}
