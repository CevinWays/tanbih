/// Durations the UI is built around.
///
/// Kept out of the widgets for the same reason spacing is: a magic number in
/// a build method is a decision nobody can find again.
abstract final class AppDurations {
  /// How long the hero keeps saying "it's time" after a prayer arrives.
  ///
  /// Long enough to outlast the start of the adhan and a glance at the
  /// phone, short enough not to hide the next countdown.
  static const Duration arrivalHold = Duration(minutes: 2);

  /// How often the countdown recomputes.
  static const Duration tick = Duration(seconds: 1);
}
