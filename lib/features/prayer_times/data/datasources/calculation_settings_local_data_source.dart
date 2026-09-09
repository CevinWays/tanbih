import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/calculation_presets.dart';
import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/calculation_settings.dart';

/// Persistence for [CalculationSettings].
abstract class CalculationSettingsLocalDataSource {
  CalculationSettings read();
  Future<void> write(CalculationSettings settings);
}

@LazySingleton(as: CalculationSettingsLocalDataSource)
class CalculationSettingsLocalDataSourceImpl
    implements CalculationSettingsLocalDataSource {
  CalculationSettingsLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'prayer_times.calculation_settings';

  @override
  CalculationSettings read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const CalculationSettings();

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(json);
    } on Object {
      // A corrupt or outdated blob must not brick the app: prayer times are
      // the whole point, so fall back to the Indonesian defaults.
      return const CalculationSettings();
    }
  }

  @override
  Future<void> write(CalculationSettings settings) async {
    final ok = await _prefs.setString(_key, jsonEncode(_toJson(settings)));
    if (!ok) throw const CacheException(message: 'Gagal menyimpan pengaturan');
  }

  static Map<String, dynamic> _toJson(CalculationSettings s) => {
    'method': s.method.storageKey,
    'madhab': s.madhab.storageKey,
    'high_latitude_rule': s.highLatitudeRule.storageKey,
    'adjust_isha_in_ramadan': s.adjustIshaInRamadan,
    'adjust_daylight_saving': s.adjustDaylightSaving,
    'jumuah_hour': s.jumuahHour,
    'jumuah_minute': s.jumuahMinute,
    'manual_adjustments': {
      for (final entry in s.manualAdjustments.entries)
        entry.key.name: entry.value,
    },
    'imsak_offset_minutes': s.imsakOffsetMinutes,
    'hijri_offset_days': s.hijriOffsetDays,
  };

  static CalculationSettings _fromJson(Map<String, dynamic> json) {
    final rawAdjustments =
        (json['manual_adjustments'] as Map?)?.cast<String, dynamic>() ?? {};

    final adjustments = <PrayerSlot, int>{};
    for (final entry in rawAdjustments.entries) {
      final slot = PrayerSlot.values
          .where((s) => s.name == entry.key)
          .firstOrNull;
      final minutes = entry.value;
      if (slot != null && minutes is int) adjustments[slot] = minutes;
    }

    return CalculationSettings(
      method: CalculationMethodId.fromStorageKey(json['method'] as String?),
      madhab: MadhabId.fromStorageKey(json['madhab'] as String?),
      highLatitudeRule: HighLatitudeRuleId.fromStorageKey(
        json['high_latitude_rule'] as String?,
      ),
      adjustIshaInRamadan: json['adjust_isha_in_ramadan'] as bool? ?? false,
      adjustDaylightSaving: json['adjust_daylight_saving'] as bool? ?? false,
      jumuahHour: json['jumuah_hour'] as int?,
      jumuahMinute: json['jumuah_minute'] as int?,
      manualAdjustments: adjustments,
      imsakOffsetMinutes:
          json['imsak_offset_minutes'] as int? ??
          CalculationSettings.defaultImsakOffsetMinutes,
      hijriOffsetDays: json['hijri_offset_days'] as int? ?? 0,
    );
  }
}
