import 'package:flutter/material.dart';

/// Brand and surface colors.
///
/// Values come from the Tanbih brand board in Figma plus the app screens.
/// Nothing outside this file may hardcode a color literal.
abstract final class AppColors {
  // Brand — "Teal to Mint" (G1)
  static const Color brandTeal = Color(0xFF2DB1B3);
  static const Color brandMint = Color(0xFF7AC793);

  /// Mid-point of the brand gradient, for places that need one flat brand
  /// color (icons, indicators, ripples).
  static const Color brandSolid = Color(0xFF54BCA3);

  // Text
  static const Color textPrimary = Color(0xFF373232);
  static const Color textSecondary = Color(0xFF6B6565);
  static const Color textOnBrand = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFFF2F4F5);
  static const Color textSecondaryDark = Color(0xFFA8B0B5);

  // Surfaces — light. The page ground comes straight from the Figma Home
  // frame; the brand gradient header sits on top of it.
  static const Color surfaceLight = Color(0xFFE2F4F7);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Surfaces — dark, taken from the brand board's navy ground
  static const Color surfaceDark = Color(0xFF0E1A24);
  static const Color cardDark = Color(0xFF16242F);

  // Glassmorphism layers, per the Figma spec
  static const Color glassFill = Color(0x40FFFFFF); // rgba(255,255,255,0.25)
  static const Color glassBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const Color glassFillStrong = Color(0x80FFFFFF); // 0.50

  /// Border drawn around the gradient header — a translucent mint that
  /// softens where the header meets the page ground.
  static const Color headerEdge = Color(0x4079C794); // rgba(121,199,148,0.25)
  static const Color glassBorderStrong = Color(0x40FFFFFF); // 0.25

  static const Color glassFillDark = Color(0x1FFFFFFF);
  static const Color glassBorderDark = Color(0x14FFFFFF);

  // Status
  static const Color success = Color(0xFF3E9E6B);
  static const Color warning = Color(0xFFD9A21B);
  static const Color error = Color(0xFFC2453C);

  static const Color divider = Color(0x14373232);
  static const Color dividerDark = Color(0x1FFFFFFF);

  /// Wash behind the prayer currently in effect, inside the grouped schedule.
  ///
  /// Replaces the per-card fill the rows used to carry: a row sharing one
  /// card with its neighbours cannot tint the card.
  static const Color rowHighlight = Color(0x1F54BCA3); // brandSolid @ 12%

  /// Darkened brand teal, for accent-coloured text on a light glass card.
  ///
  /// [brandSolid] on that ground measures about 2.2:1 — well under the 4.5:1
  /// floor for 14px text. This measures 5.1:1. On dark surfaces use
  /// [brandMint] instead, which measures 7.2:1 there.
  static const Color brandOnSurface = Color(0xFF17766A);
}
