import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

/// Shorthand for reading localized strings: `context.l10n.prayerFajr`.
///
/// Every user-visible string goes through this. See CLAUDE.md § Localization.
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
