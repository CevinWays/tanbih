import '../l10n/generated/app_localizations.dart';

/// Whole seconds left, rounded **up**, never below zero.
///
/// Rounding up matters: flooring a 300ms remainder would print `0:00` while
/// the prayer time has not actually arrived — the same lie the old
/// minute-resolution countdown told, one unit down. Rounded up, `0:00` can
/// only appear at or after the target instant.
int countdownSeconds(Duration remaining) {
  if (remaining <= Duration.zero) return 0;
  return (remaining.inMicroseconds / Duration.microsecondsPerSecond).ceil();
}

/// The countdown as digits: `39:07` under an hour, `5:12:44` above it.
///
/// Not an ARB message. Both supported locales use the same digits and the
/// same `:` separator, so there is nothing to translate, and ICU cannot
/// zero-pad a placeholder — the padding would have to happen in Dart anyway,
/// leaving the ARB entry as an empty indirection that can only go wrong.
/// The words around the number ("Tersisa", "Sudah masuk waktu") stay
/// localized.
String formatCountdown(Duration remaining) {
  final total = countdownSeconds(remaining);

  final hours = total ~/ Duration.secondsPerHour;
  final minutes =
      (total % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;
  final seconds = total % Duration.secondsPerMinute;

  final ss = seconds.toString().padLeft(2, '0');

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$ss';
  }
  return '$minutes:$ss';
}

/// The same duration in words, for screen readers.
///
/// `39:07` is read out as "thirty-nine oh seven", which is meaningless. The
/// minute-based ARB messages are exactly right here, which is why they
/// outlived the visual formatter that used to be their only caller.
String countdownSemanticDuration(AppLocalizations l10n, Duration remaining) {
  final total = countdownSeconds(remaining);

  final hours = total ~/ Duration.secondsPerHour;
  final minutes =
      (total % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;

  return hours > 0
      ? l10n.countdownHoursMinutes(hours, minutes)
      : l10n.countdownMinutes(minutes);
}
