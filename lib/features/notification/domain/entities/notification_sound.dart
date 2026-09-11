/// Sound a prayer notification plays.
///
/// The Android channel id embeds this value because a channel's sound is
/// immutable once created — changing the sound means creating a new channel,
/// never editing the old one. See [channelId].
enum NotificationSound {
  /// No sound. Used on its own, and also when the full adhan plays through
  /// the native alarm path, so the two do not overlap.
  silent,

  /// The device's default notification tone.
  defaultTone,

  /// A short adhan clip bundled in `res/raw`.
  ///
  /// Thirty seconds exactly, cut on a phrase boundary — see
  /// assets/audio/CREDITS.md.
  adhanShort;

  String get storageKey => name;

  static NotificationSound fromStorageKey(String? key) => values.firstWhere(
    (s) => s.storageKey == key,
    orElse: () => NotificationSound.defaultTone,
  );

  /// Raw resource name for the channel sound, or null for the default tone.
  String? get rawResource => switch (this) {
    NotificationSound.silent => null,
    NotificationSound.defaultTone => null,
    NotificationSound.adhanShort => 'adhan_short',
  };

  /// Version suffix on the channel id.
  ///
  /// Bump this when a bundled sound file is replaced: Android keeps serving
  /// the sound a channel was created with, so a new file needs a new channel
  /// or users keep hearing the old one.
  static const int channelVersion = 1;

  /// Android notification channel for this sound.
  String get channelId => 'prayer_${storageKey}_v$channelVersion';
}
