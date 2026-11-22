import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens.
///
/// Styles that sit inside cards deliberately carry no colour. The theme's
/// text colours differ between light and dark, and pinning one here painted
/// dark text onto dark surfaces — legible in the designs, unreadable on a
/// phone in dark mode. Only styles drawn on the brand gradient, where the
/// ground is the same in both themes, set a colour explicitly.
///
/// Two families, per the brand board:
/// * **Outfit** — wordmark and headings. Shipped as a variable font, so the
///   weight is selected with [FontVariation] rather than [FontWeight] alone;
///   `fontWeight` is still set so that any fallback face picks a sane weight.
/// * **Poppins** — body text, matching the app screens in Figma.
abstract final class AppTextStyle {
  static const String fontHeading = 'Outfit';
  static const String fontBody = 'Poppins';

  static List<FontVariation> _wght(double w) => [FontVariation('wght', w)];

  // ---- Headings (Outfit) ----

  /// The wordmark itself — splash and About.
  static const TextStyle wordmark = TextStyle(
    fontFamily: fontHeading,
    fontSize: 40,
    height: 1.1,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle h1 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontVariations: _wght(700),
  );

  static final TextStyle h2 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
  );

  static final TextStyle h3 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
  );

  // ---- Body (Poppins) ----

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnBrand,
  );

  // ---- Countdown card (exact sizes from Figma node 2002:55899) ----

  /// Prayer name inside the circular countdown.
  static const TextStyle countdownPrayer = TextStyle(
    fontFamily: fontBody,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  /// "1 hr & 33 min".
  static const TextStyle countdownValue = TextStyle(
    fontFamily: fontBody,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// The ticking digits — "39:07", "5:12:44".
  ///
  /// Tabular figures so the number does not jitter sideways every second.
  static const TextStyle countdownTimer = TextStyle(
    fontFamily: fontBody,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// The clock time of the prayer being counted down to.
  static const TextStyle countdownTarget = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// "Remaining".
  static const TextStyle countdownCaption = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  /// Prayer name in the schedule list.
  static const TextStyle rowLabel = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Small caption on the gradient header (dates, location).
  static const TextStyle onHeaderCaption = TextStyle(
    fontFamily: fontBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const TextStyle onHeaderLabel = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  /// Prayer time in the schedule list — tabular so digits do not jitter as
  /// the countdown ticks.
  static const TextStyle prayerTime = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// The prayer currently in effect, in the schedule list.
  ///
  /// Weight carries the emphasis and the colour is left to the theme. The
  /// brand teal reads at about 2.2:1 on the light card, so using it for text
  /// here would fail contrast — the accent lives in the marker pill and the
  /// row wash instead.
  static final TextStyle rowLabelActive = rowLabel.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final TextStyle prayerTimeActive = prayerTime.copyWith(
    fontWeight: FontWeight.w700,
  );

  /// The imsak / iftaar times, which the design sets larger than a row.
  static const TextStyle pairTime = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Trailing value on a summary row — "294° · 8.582 km ke Makkah".
  static const TextStyle rowValue = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
