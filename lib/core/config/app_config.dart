/// Compile-time and constant configuration.
///
/// Tanbih has no backend of its own. [remoteBaseUrl] serves only optional
/// enhancements (adhan voice catalog, remote calculation presets); every
/// feature behind it must degrade gracefully when unreachable.
abstract final class AppConfig {
  static const String appName = 'Tanbih';

  /// Static asset host for optional downloads. Overridable at build time:
  /// `--dart-define=TANBIH_REMOTE_BASE_URL=...`
  static const String remoteBaseUrl = String.fromEnvironment(
    'TANBIH_REMOTE_BASE_URL',
    defaultValue: 'https://tanbih-assets.pages.dev',
  );

  /// Nominatim requires a descriptive User-Agent identifying the app.
  static const String geocodingBaseUrl = 'https://nominatim.openstreetmap.org';

  static const Duration httpConnectTimeout = Duration(seconds: 15);
  static const Duration httpReceiveTimeout = Duration(seconds: 15);

  /// How many days ahead notifications are scheduled in one pass.
  ///
  /// Seven days × up to 7 slots stays under the 60-notification ceiling the
  /// scheduler enforces (which also keeps iOS's hard limit of 64 in reach).
  static const int scheduleWindowDays = 7;
  static const int maxPendingNotifications = 60;

  /// Re-resolve the schedule when the device has moved further than this
  /// from the coordinates the current schedule was built from.
  static const double rescheduleDistanceThresholdMeters = 5000;

  /// Daily housekeeping pass that extends the scheduling window.
  static const int housekeepingHour = 0;
  static const int housekeepingMinute = 10;
}
