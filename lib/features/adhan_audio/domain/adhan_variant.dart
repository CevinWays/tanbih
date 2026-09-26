import '../../../core/enums/prayer_slot.dart';

/// Which adhan recording a prayer calls for.
///
/// The Fajr adhan is not the same as the others: after "hayya 'alal falah"
/// it adds the tathwib — "as-salatu khayrun min an-nawm", prayer is better
/// than sleep — recited twice, and only at Fajr. Playing the ordinary adhan
/// at Fajr is audibly wrong to anyone who knows it.
enum AdhanVariant {
  standard,
  fajr;

  static AdhanVariant forSlot(PrayerSlot slot) =>
      slot == PrayerSlot.fajr ? AdhanVariant.fajr : AdhanVariant.standard;

  /// Flutter asset played by the native service for the full adhan.
  ///
  /// Both entries point at the same recording today: no adhan with the
  /// tathwib could be found under a licence that permits redistribution.
  /// Wikimedia Commons has none, every Internet Archive copy is an
  /// uploaded commercial recording with no licence stated, and the CC0
  /// material on Freesound is distant field audio with room noise.
  /// Substituting one of those would repeat the mistake the credits file
  /// already documents. Dropping a proper Fajr recording in is a change to
  /// this one line plus the asset.
  String get fullAsset => switch (this) {
    AdhanVariant.standard => 'assets/audio/adhan_full.ogg',
    // TODO(audio): point at assets/audio/adhan_fajr_full.ogg once a
    // recording with the tathwib is available under a clear licence.
    AdhanVariant.fajr => 'assets/audio/adhan_full.ogg',
  };

  /// Whether this variant still falls back to the ordinary recording.
  ///
  /// Surfaced so the UI can be honest about it rather than implying a
  /// distinction the audio does not yet make.
  bool get usesFallbackRecording => this == AdhanVariant.fajr;
}
