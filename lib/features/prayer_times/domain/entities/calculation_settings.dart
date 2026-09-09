import 'package:equatable/equatable.dart';

import '../../../../core/config/calculation_presets.dart';
import '../../../../core/enums/prayer_slot.dart';

/// Everything the user can change about how times are computed.
///
/// Persisted as JSON. Defaults are tuned for Indonesia: Kemenag method,
/// Shafi'i Asr, 10-minute imsak margin.
class CalculationSettings extends Equatable {
  const CalculationSettings({
    this.method = CalculationMethodId.kemenag,
    this.madhab = MadhabId.shafi,
    this.highLatitudeRule = HighLatitudeRuleId.middleOfTheNight,
    this.adjustIshaInRamadan = false,
    this.adjustDaylightSaving = false,
    this.jumuahHour,
    this.jumuahMinute,
    this.manualAdjustments = const {},
    this.imsakOffsetMinutes = defaultImsakOffsetMinutes,
    this.hijriOffsetDays = 0,
  });

  /// Imsak is not computed by the astronomical model — it is Fajr minus a
  /// margin. Ten minutes is the value Indonesian timetables use.
  static const int defaultImsakOffsetMinutes = 10;

  final CalculationMethodId method;
  final MadhabId madhab;
  final HighLatitudeRuleId highLatitudeRule;

  /// Adds 30 minutes to Isha during Ramadan. Only meaningful for Umm al-Qura,
  /// which is why the UI hides it for every other method.
  final bool adjustIshaInRamadan;

  /// Manual +1 hour correction, for devices whose reported zone lags a DST
  /// change. Independent of the device timezone.
  final bool adjustDaylightSaving;

  /// Local Jumu'ah time. When set, it replaces Dhuhr on Fridays — mosques
  /// rarely start exactly at the astronomical Dhuhr.
  final int? jumuahHour;
  final int? jumuahMinute;

  /// Per-slot offsets in minutes, on top of the method's own ihtiyati.
  final Map<PrayerSlot, int> manualAdjustments;

  final int imsakOffsetMinutes;

  /// ±days correction for the Hijri date, since the civil calendar and local
  /// moon sighting can differ by a day or two.
  final int hijriOffsetDays;

  bool get hasJumuahTime => jumuahHour != null && jumuahMinute != null;

  /// Whether the Ramadan switch should have any effect, guarding against a
  /// stale `true` left behind after the user switches away from Umm al-Qura.
  bool get ramadanIshaAdjustmentActive =>
      adjustIshaInRamadan && method.supportsRamadanIshaAdjustment;

  int adjustmentFor(PrayerSlot slot) => manualAdjustments[slot] ?? 0;

  CalculationSettings copyWith({
    CalculationMethodId? method,
    MadhabId? madhab,
    HighLatitudeRuleId? highLatitudeRule,
    bool? adjustIshaInRamadan,
    bool? adjustDaylightSaving,
    int? jumuahHour,
    int? jumuahMinute,
    bool clearJumuah = false,
    Map<PrayerSlot, int>? manualAdjustments,
    int? imsakOffsetMinutes,
    int? hijriOffsetDays,
  }) {
    return CalculationSettings(
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      highLatitudeRule: highLatitudeRule ?? this.highLatitudeRule,
      adjustIshaInRamadan: adjustIshaInRamadan ?? this.adjustIshaInRamadan,
      adjustDaylightSaving: adjustDaylightSaving ?? this.adjustDaylightSaving,
      jumuahHour: clearJumuah ? null : (jumuahHour ?? this.jumuahHour),
      jumuahMinute: clearJumuah ? null : (jumuahMinute ?? this.jumuahMinute),
      manualAdjustments: manualAdjustments ?? this.manualAdjustments,
      imsakOffsetMinutes: imsakOffsetMinutes ?? this.imsakOffsetMinutes,
      hijriOffsetDays: hijriOffsetDays ?? this.hijriOffsetDays,
    );
  }

  @override
  List<Object?> get props => [
    method,
    madhab,
    highLatitudeRule,
    adjustIshaInRamadan,
    adjustDaylightSaving,
    jumuahHour,
    jumuahMinute,
    manualAdjustments,
    imsakOffsetMinutes,
    hijriOffsetDays,
  ];
}
