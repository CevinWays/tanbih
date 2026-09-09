import '../config/calculation_presets.dart';
import '../l10n/generated/app_localizations.dart';

/// Localized names for the calculation options.
///
/// Kept out of `core/config` so the enums stay free of localization imports
/// and can be used from the data layer.
extension CalculationMethodLabel on CalculationMethodId {
  String label(AppLocalizations l10n) => switch (this) {
    CalculationMethodId.kemenag => l10n.methodKemenag,
    CalculationMethodId.muslimWorldLeague => l10n.methodMwl,
    CalculationMethodId.egyptian => l10n.methodEgyptian,
    CalculationMethodId.karachi => l10n.methodKarachi,
    CalculationMethodId.ummAlQura => l10n.methodUmmAlQura,
    CalculationMethodId.dubai => l10n.methodDubai,
    CalculationMethodId.moonSightingCommittee => l10n.methodMoonsighting,
    CalculationMethodId.northAmerica => l10n.methodIsna,
    CalculationMethodId.kuwait => l10n.methodKuwait,
    CalculationMethodId.qatar => l10n.methodQatar,
    CalculationMethodId.singapore => l10n.methodSingapore,
    CalculationMethodId.turkey => l10n.methodTurkey,
    CalculationMethodId.tehran => l10n.methodTehran,
  };

  /// Only Kemenag carries a recommendation, since the app targets Indonesia.
  String? subtitle(AppLocalizations l10n) =>
      this == CalculationMethodId.kemenag ? l10n.methodKemenagSubtitle : null;
}

extension MadhabLabel on MadhabId {
  String label(AppLocalizations l10n) => switch (this) {
    MadhabId.shafi => l10n.madhabShafi,
    MadhabId.hanafi => l10n.madhabHanafi,
  };
}

extension HighLatitudeRuleLabel on HighLatitudeRuleId {
  String label(AppLocalizations l10n) => switch (this) {
    HighLatitudeRuleId.middleOfTheNight => l10n.highLatMiddle,
    HighLatitudeRuleId.seventhOfTheNight => l10n.highLatSeventh,
    HighLatitudeRuleId.twilightAngle => l10n.highLatTwilight,
  };
}
