/// A row in the daily schedule.
///
/// Lives in `core/` rather than inside `features/prayer_times/domain/`
/// because three features need it (prayer_times, notification, silent_mode)
/// and features must not import each other's domain layer.
///
/// Order is chronological — iteration order is the display order.
enum PrayerSlot {
  imsak,
  fajr,
  sunrise,
  dhuhr,
  jumuah,
  asr,
  maghrib,
  isha;

  /// True for the five obligatory prayers plus Jumuah.
  ///
  /// Imsak and sunrise are informational rows: no adhan, no notification,
  /// and they are skipped by the scheduler.
  bool get isPrayer => switch (this) {
    PrayerSlot.imsak || PrayerSlot.sunrise => false,
    _ => true,
  };

  /// Whether this slot can trigger the adhan.
  ///
  /// Jumuah replaces Dhuhr on Fridays, so both are adhan-capable.
  bool get canPlayAdhan => isPrayer;

  /// Stable index used to build deterministic notification ids
  /// (`daysSinceEpoch * 20 + slotIndex`). Never reorder this enum without
  /// cancelling all pending notifications first — existing ids would
  /// resolve to the wrong prayer.
  int get slotIndex => index;
}
