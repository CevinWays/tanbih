import 'package:adhan/adhan.dart' as adhan;
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/config/calculation_presets.dart';
import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/calculation_settings.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/entities/hijri_date.dart';
import '../../domain/entities/prayer_time_entry.dart';

/// Computes a day's prayer times.
///
/// **The only file in the app that imports `adhan`.** If the package ever has
/// to be replaced or forked, this is the single point of change — see
/// CLAUDE.md § Do NOT.
abstract class AdhanCalculatorDataSource {
  /// [timeZoneId] is an IANA zone name (`Asia/Jakarta`). Times are resolved
  /// in *that* zone, never in the device's — a phone set to the wrong zone,
  /// or a manually chosen city in another zone, must not shift the schedule.
  DailyPrayerTimes calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String timeZoneId,
    required CalculationSettings settings,
    required HijriDate hijriDate,
  });

  /// Qibla bearing from true north, clockwise, in degrees.
  double qiblaDirection({required double latitude, required double longitude});
}

@LazySingleton(as: AdhanCalculatorDataSource)
class AdhanCalculatorDataSourceImpl implements AdhanCalculatorDataSource {
  const AdhanCalculatorDataSourceImpl();

  /// Minutes added to Isha during Ramadan under Umm al-Qura.
  static const int _ramadanIshaMinutes = 30;

  /// Manual daylight-saving correction.
  static const int _daylightSavingMinutes = 60;

  @override
  DailyPrayerTimes calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String timeZoneId,
    required CalculationSettings settings,
    required HijriDate hijriDate,
  }) {
    try {
      final coordinates = adhan.Coordinates(
        latitude,
        longitude,
        validate: true,
      );
      final params = _buildParameters(settings, hijriDate);
      final location = tz.getLocation(timeZoneId);

      // The offset is read at midday of the target date so a DST transition
      // that happens overnight cannot pick the wrong side of the change.
      final offset = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
        12,
      ).timeZoneOffset;

      final times = adhan.PrayerTimes(
        coordinates,
        adhan.DateComponents(date.year, date.month, date.day),
        params,
        utcOffset: offset,
      );

      return DailyPrayerTimes(
        date: tz.TZDateTime(location, date.year, date.month, date.day),
        entries: _buildEntries(times, date, location, settings),
        hijriDate: hijriDate,
      );
    } on tz.LocationNotFoundException catch (e) {
      throw CalculationException(message: 'Zona waktu tidak dikenal: ${e.msg}');
    } on ArgumentError catch (e) {
      throw CalculationException(
        message: 'Koordinat tidak valid: ${e.message}',
      );
    } on Exception catch (e) {
      throw CalculationException(message: e.toString());
    }
  }

  @override
  double qiblaDirection({
    required double latitude,
    required double longitude,
  }) => adhan.Qibla(adhan.Coordinates(latitude, longitude)).direction;

  /// Builds the `adhan` parameters for these settings.
  ///
  /// Two adjustment channels are kept deliberately separate:
  /// * `methodAdjustments` — set by the preset itself (Kemenag's ihtiyati,
  ///   MWL's +1 on Dhuhr). Never overwritten here.
  /// * `adjustments` — everything the user controls, plus the DST and Ramadan
  ///   corrections. `adhan` adds both channels, so they compose.
  adhan.CalculationParameters _buildParameters(
    CalculationSettings settings,
    HijriDate hijriDate,
  ) {
    final params = CalculationPresets.parametersFor(settings.method)
      ..madhab = settings.madhab.toAdhan
      ..highLatitudeRule = settings.highLatitudeRule.toAdhan;

    final dst = settings.adjustDaylightSaving ? _daylightSavingMinutes : 0;
    final ramadanIsha =
        settings.ramadanIshaAdjustmentActive && hijriDate.isRamadan
        ? _ramadanIshaMinutes
        : 0;

    params.adjustments = adhan.PrayerAdjustments(
      fajr: settings.adjustmentFor(PrayerSlot.fajr) + dst,
      sunrise: settings.adjustmentFor(PrayerSlot.sunrise) + dst,
      dhuhr: settings.adjustmentFor(PrayerSlot.dhuhr) + dst,
      asr: settings.adjustmentFor(PrayerSlot.asr) + dst,
      maghrib: settings.adjustmentFor(PrayerSlot.maghrib) + dst,
      isha: settings.adjustmentFor(PrayerSlot.isha) + dst + ramadanIsha,
    );

    return params;
  }

  /// Assembles the chronological rows.
  ///
  /// Imsak is derived (Fajr minus the configured margin) because it is not an
  /// astronomical event. Jumu'ah *replaces* Dhuhr on Fridays when the user
  /// has set a time, so the list never shows both.
  List<PrayerTimeEntry> _buildEntries(
    adhan.PrayerTimes times,
    DateTime date,
    tz.Location location,
    CalculationSettings settings,
  ) {
    final fajr = _toZoned(times.fajr, location);

    final imsak = fajr.subtract(
      Duration(
        minutes:
            settings.imsakOffsetMinutes -
            settings.adjustmentFor(PrayerSlot.imsak),
      ),
    );

    return [
      PrayerTimeEntry(slot: PrayerSlot.imsak, time: imsak),
      PrayerTimeEntry(slot: PrayerSlot.fajr, time: fajr),
      PrayerTimeEntry(
        slot: PrayerSlot.sunrise,
        time: _toZoned(times.sunrise, location),
      ),
      _middayEntry(times, date, location, settings),
      PrayerTimeEntry(
        slot: PrayerSlot.asr,
        time: _toZoned(times.asr, location),
      ),
      PrayerTimeEntry(
        slot: PrayerSlot.maghrib,
        time: _toZoned(times.maghrib, location),
      ),
      PrayerTimeEntry(
        slot: PrayerSlot.isha,
        time: _toZoned(times.isha, location),
      ),
    ];
  }

  /// Rebuilds one of `adhan`'s results as a real instant in [location].
  ///
  /// When `utcOffset` is supplied, `adhan` returns the target zone's wall
  /// clock but flags the value as UTC. Comparing that against
  /// `DateTime.now()` or handing it to the notification scheduler would be
  /// wrong by the size of the offset, so the wall-clock fields are read back
  /// out and re-anchored in the zone.
  tz.TZDateTime _toZoned(DateTime wallClock, tz.Location location) =>
      tz.TZDateTime(
        location,
        wallClock.year,
        wallClock.month,
        wallClock.day,
        wallClock.hour,
        wallClock.minute,
      );

  PrayerTimeEntry _middayEntry(
    adhan.PrayerTimes times,
    DateTime date,
    tz.Location location,
    CalculationSettings settings,
  ) {
    final isFriday = date.weekday == DateTime.friday;
    if (!isFriday || !settings.hasJumuahTime) {
      return PrayerTimeEntry(
        slot: PrayerSlot.dhuhr,
        time: _toZoned(times.dhuhr, location),
      );
    }

    // Jumu'ah is a wall-clock time the user typed, not an astronomical
    // event, so it is anchored directly in the zone.
    final jumuah = tz.TZDateTime(
      location,
      date.year,
      date.month,
      date.day,
      settings.jumuahHour!,
      settings.jumuahMinute!,
    ).add(Duration(minutes: settings.adjustmentFor(PrayerSlot.jumuah)));

    return PrayerTimeEntry(slot: PrayerSlot.jumuah, time: jumuah);
  }
}
