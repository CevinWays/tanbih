import 'package:adhan/adhan.dart' as adhan;

/// Calculation methods offered in Settings.
///
/// Wraps `adhan`'s 13 presets and adds [kemenag], which the package does not
/// ship. The wrapper exists so the rest of the app never imports `adhan`
/// directly — only `AdhanCalculatorDataSource` does.
enum CalculationMethodId {
  /// Kementerian Agama Republik Indonesia — the default.
  ///
  /// Fajr 20°, Isha 18°, plus the *ihtiyati* safety margin Indonesian
  /// schedules apply: +2 minutes on every prayer and −2 on sunrise.
  kemenag,
  muslimWorldLeague,
  egyptian,
  karachi,
  ummAlQura,
  dubai,
  moonSightingCommittee,
  northAmerica,
  kuwait,
  qatar,
  singapore,
  turkey,
  tehran;

  /// Only Umm al-Qura defines the Ramadan Isha correction, so the
  /// "Adjust Isha in Ramadan" switch is hidden for every other method.
  bool get supportsRamadanIshaAdjustment =>
      this == CalculationMethodId.ummAlQura;

  /// Persisted verbatim in SharedPreferences. Keep these strings stable —
  /// renaming one silently resets a user's chosen method to the default.
  String get storageKey => switch (this) {
    CalculationMethodId.kemenag => 'kemenag',
    CalculationMethodId.muslimWorldLeague => 'muslim_world_league',
    CalculationMethodId.egyptian => 'egyptian',
    CalculationMethodId.karachi => 'karachi',
    CalculationMethodId.ummAlQura => 'umm_al_qura',
    CalculationMethodId.dubai => 'dubai',
    CalculationMethodId.moonSightingCommittee => 'moon_sighting_committee',
    CalculationMethodId.northAmerica => 'north_america',
    CalculationMethodId.kuwait => 'kuwait',
    CalculationMethodId.qatar => 'qatar',
    CalculationMethodId.singapore => 'singapore',
    CalculationMethodId.turkey => 'turkey',
    CalculationMethodId.tehran => 'tehran',
  };

  static CalculationMethodId fromStorageKey(String? key) => values.firstWhere(
    (m) => m.storageKey == key,
    orElse: () => CalculationMethodId.kemenag,
  );
}

/// *Ihtiyati* — the safety margin Indonesian timetables apply — expressed as
/// minutes to add to the raw astronomical result.
///
/// Kemenag documents a nominal 2-minute margin, but its published tables sit
/// slightly further out than a plain +2 because the official computation also
/// rounds outward. These values were calibrated against the Kemenag timetable
/// for Jakarta (see `tool/kemenag_check.dart`) across four dates spanning
/// both solstices and an equinox; residual error is at most 1 minute per
/// prayer.
///
/// Every deviation is biased in the *safe* direction — prayers land slightly
/// later and sunrise slightly earlier, so a user never prays before a time
/// has actually begun.
abstract final class KemenagIhtiyati {
  static const double fajrAngle = 20.0;
  static const double ishaAngle = 18.0;

  static const int fajr = 2;

  /// Negative: sunrise ends the Fajr window, so pulling it earlier is the
  /// conservative choice.
  static const int sunrise = -3;

  static const int dhuhr = 4;
  static const int asr = 3;
  static const int maghrib = 4;
  static const int isha = 2;
}

/// Translates a [CalculationMethodId] into `adhan` parameters.
///
/// The only place in the app allowed to build `adhan` types besides
/// `AdhanCalculatorDataSource`.
abstract final class CalculationPresets {
  static adhan.CalculationParameters parametersFor(CalculationMethodId id) {
    if (id == CalculationMethodId.kemenag) return _kemenag();
    return _adhanMethod(id).getParameters();
  }

  static adhan.CalculationParameters _kemenag() {
    return adhan.CalculationParameters(
      method: adhan.CalculationMethod.other,
      fajrAngle: KemenagIhtiyati.fajrAngle,
      ishaAngle: KemenagIhtiyati.ishaAngle,
    ).withMethodAdjustments(
      adhan.PrayerAdjustments(
        fajr: KemenagIhtiyati.fajr,
        sunrise: KemenagIhtiyati.sunrise,
        dhuhr: KemenagIhtiyati.dhuhr,
        asr: KemenagIhtiyati.asr,
        maghrib: KemenagIhtiyati.maghrib,
        isha: KemenagIhtiyati.isha,
      ),
    );
  }

  static adhan.CalculationMethod _adhanMethod(CalculationMethodId id) =>
      switch (id) {
        CalculationMethodId.muslimWorldLeague =>
          adhan.CalculationMethod.muslim_world_league,
        CalculationMethodId.egyptian => adhan.CalculationMethod.egyptian,
        CalculationMethodId.karachi => adhan.CalculationMethod.karachi,
        CalculationMethodId.ummAlQura => adhan.CalculationMethod.umm_al_qura,
        CalculationMethodId.dubai => adhan.CalculationMethod.dubai,
        CalculationMethodId.moonSightingCommittee =>
          adhan.CalculationMethod.moon_sighting_committee,
        CalculationMethodId.northAmerica =>
          adhan.CalculationMethod.north_america,
        CalculationMethodId.kuwait => adhan.CalculationMethod.kuwait,
        CalculationMethodId.qatar => adhan.CalculationMethod.qatar,
        CalculationMethodId.singapore => adhan.CalculationMethod.singapore,
        CalculationMethodId.turkey => adhan.CalculationMethod.turkey,
        CalculationMethodId.tehran => adhan.CalculationMethod.tehran,
        // Handled before this switch is reached.
        CalculationMethodId.kemenag => adhan.CalculationMethod.other,
      };
}

/// Asr calculation school.
enum MadhabId {
  /// Majority in Indonesia — earlier Asr.
  shafi,

  /// Later Asr.
  hanafi;

  String get storageKey => name;

  static MadhabId fromStorageKey(String? key) => values.firstWhere(
    (m) => m.storageKey == key,
    orElse: () => MadhabId.shafi,
  );

  adhan.Madhab get toAdhan => switch (this) {
    MadhabId.shafi => adhan.Madhab.shafi,
    MadhabId.hanafi => adhan.Madhab.hanafi,
  };
}

/// How Fajr and Isha are resolved where the sun never reaches the required
/// angle. Irrelevant in Indonesia, but the setting exists in the design.
enum HighLatitudeRuleId {
  middleOfTheNight,
  seventhOfTheNight,
  twilightAngle;

  String get storageKey => name;

  static HighLatitudeRuleId fromStorageKey(String? key) => values.firstWhere(
    (r) => r.storageKey == key,
    orElse: () => HighLatitudeRuleId.middleOfTheNight,
  );

  adhan.HighLatitudeRule get toAdhan => switch (this) {
    HighLatitudeRuleId.middleOfTheNight =>
      adhan.HighLatitudeRule.middle_of_the_night,
    HighLatitudeRuleId.seventhOfTheNight =>
      adhan.HighLatitudeRule.seventh_of_the_night,
    HighLatitudeRuleId.twilightAngle => adhan.HighLatitudeRule.twilight_angle,
  };
}
