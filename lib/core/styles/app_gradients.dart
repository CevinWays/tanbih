import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradients used across the app. The primary one is the brand signature.
abstract final class AppGradients {
  /// Brand gradient G1 — `#2DB1B3 → #7AC793`.
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.brandTeal, AppColors.brandMint],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Same hues, vertical — for full-bleed backgrounds where a diagonal
  /// sweep would fight the layout.
  static const LinearGradient primaryVertical = LinearGradient(
    colors: [AppColors.brandTeal, AppColors.brandMint],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Overlay that keeps white text legible on top of an illustration.
  static const LinearGradient scrim = LinearGradient(
    colors: [Color(0x00000000), Color(0x66000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
