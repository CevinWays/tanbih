import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens.
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
    color: AppColors.textPrimary,
  );

  static final TextStyle h2 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    color: AppColors.textPrimary,
  );

  static final TextStyle h3 = TextStyle(
    fontFamily: fontHeading,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontVariations: _wght(600),
    color: AppColors.textPrimary,
  );

  // ---- Body (Poppins) ----

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
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

  /// "Remaining".
  static const TextStyle countdownCaption = TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  /// Prayer time in the schedule list — tabular so digits do not jitter as
  /// the countdown ticks.
  static const TextStyle prayerTime = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.textPrimary,
  );
}
