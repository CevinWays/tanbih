import 'package:injectable/injectable.dart';

/// Ambient values the data layer needs but cannot reach on its own.
///
/// The device time zone comes from a plugin at startup, and the active
/// language lives in a cubit — neither is available to a data source, which
/// has no `BuildContext` and must not depend on presentation code. Rather
/// than giving repositories setters that callers must remember to call, both
/// values live here and are read at the moment they are used.
@lazySingleton
class AppContext {
  /// IANA zone of the device, e.g. `Asia/Jakarta`.
  ///
  /// Used for automatic locations and as the substitute when a searched
  /// city's zone cannot be determined. Defaults to Jakarta so a failure to
  /// read the platform zone still yields sensible times for the primary
  /// audience.
  String deviceTimeZoneId = 'Asia/Jakarta';

  /// Language for reverse-geocoded place names and Hijri month names.
  String languageCode = 'id';
}
