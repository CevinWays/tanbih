import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanbih/core/config/calculation_presets.dart';
import 'package:tanbih/core/enums/prayer_slot.dart';
import 'package:tanbih/features/prayer_times/data/datasources/calculation_settings_local_data_source.dart';
import 'package:tanbih/features/prayer_times/domain/entities/calculation_settings.dart';

void main() {
  late SharedPreferences prefs;
  late CalculationSettingsLocalDataSourceImpl dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = CalculationSettingsLocalDataSourceImpl(prefs);
  });

  test('returns the Indonesian defaults when nothing is stored', () {
    final settings = dataSource.read();

    expect(settings.method, CalculationMethodId.kemenag);
    expect(settings.madhab, MadhabId.shafi);
    expect(settings.imsakOffsetMinutes, 10);
    expect(settings.hijriOffsetDays, 0);
    expect(settings.hasJumuahTime, isFalse);
  });

  test('round-trips every field', () async {
    const original = CalculationSettings(
      method: CalculationMethodId.ummAlQura,
      madhab: MadhabId.hanafi,
      highLatitudeRule: HighLatitudeRuleId.seventhOfTheNight,
      adjustIshaInRamadan: true,
      adjustDaylightSaving: true,
      jumuahHour: 12,
      jumuahMinute: 30,
      manualAdjustments: {PrayerSlot.fajr: -2, PrayerSlot.maghrib: 3},
      imsakOffsetMinutes: 12,
      hijriOffsetDays: -1,
    );

    await dataSource.write(original);

    expect(dataSource.read(), original);
  });

  test('a corrupt blob falls back to defaults instead of throwing', () async {
    // Prayer times are the whole point of the app: a bad settings blob must
    // never be able to stop them from being shown.
    await prefs.setString(
      'prayer_times.calculation_settings',
      'not json at all',
    );

    expect(dataSource.read().method, CalculationMethodId.kemenag);
  });

  test('an unknown method key falls back to Kemenag', () async {
    await prefs.setString(
      'prayer_times.calculation_settings',
      '{"method":"some_future_method"}',
    );

    expect(dataSource.read().method, CalculationMethodId.kemenag);
  });

  test('an unknown slot in stored adjustments is dropped', () async {
    await prefs.setString(
      'prayer_times.calculation_settings',
      '{"manual_adjustments":{"fajr":3,"tahajud":9}}',
    );

    final settings = dataSource.read();
    expect(settings.adjustmentFor(PrayerSlot.fajr), 3);
    expect(settings.manualAdjustments.length, 1);
  });
}
