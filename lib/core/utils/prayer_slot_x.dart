import '../enums/prayer_slot.dart';
import '../l10n/generated/app_localizations.dart';

/// Presentation details for a prayer slot: its localized name and its icon.
///
/// Lives in `core/utils` rather than on the enum itself so the enum stays
/// free of Flutter and localization imports — it is used by the scheduler
/// and the data layer too.
extension PrayerSlotPresentation on PrayerSlot {
  String label(AppLocalizations l10n) => switch (this) {
    PrayerSlot.imsak => l10n.prayerImsak,
    PrayerSlot.fajr => l10n.prayerFajr,
    PrayerSlot.sunrise => l10n.prayerSunrise,
    PrayerSlot.dhuhr => l10n.prayerDhuhr,
    PrayerSlot.jumuah => l10n.prayerJumuah,
    PrayerSlot.asr => l10n.prayerAsr,
    PrayerSlot.maghrib => l10n.prayerMaghrib,
    PrayerSlot.isha => l10n.prayerIsha,
  };

  /// Asset name under `assets/icons/`, without extension.
  String get iconAsset => switch (this) {
    // Imsak shares Fajr's crescent: it is the same pre-dawn moment.
    PrayerSlot.imsak || PrayerSlot.fajr => 'prayer_fajr',
    PrayerSlot.sunrise => 'prayer_dhuhr',
    PrayerSlot.dhuhr || PrayerSlot.jumuah => 'prayer_dhuhr',
    PrayerSlot.asr => 'prayer_asr',
    PrayerSlot.maghrib => 'prayer_maghrib',
    PrayerSlot.isha => 'prayer_isha',
  };
}

/// Formats a duration the way the countdown does: "1 jam 33 menit", dropping
/// the hour part once under an hour.
String formatRemaining(AppLocalizations l10n, Duration remaining) {
  final total = remaining.isNegative ? Duration.zero : remaining;
  final hours = total.inHours;
  final minutes = total.inMinutes.remainder(60);

  return hours > 0
      ? l10n.countdownHoursMinutes(hours, minutes)
      : l10n.countdownMinutes(minutes);
}
