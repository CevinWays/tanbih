/// Spacing and radius scale. Widgets must not use raw numbers for layout.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Horizontal page padding used by every screen.
  static const double screenPadding = 20;

  // Radii — the design leans heavily on very round corners.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 100;

  /// Blur sigma for glassmorphism, matching Figma's `backdrop-blur: 25px`.
  ///
  /// Expensive on low-end Android — keep to roughly three instances per
  /// screen and profile on a physical device.
  static const double glassBlur = 25;

  /// Diameter of the circular countdown in the Home carousel.
  static const double countdownDiameter = 180;

  /// Inner ring inside the countdown circle.
  static const double countdownRingDiameter = 161;

  /// Height of the gradient header on Home, and the radius of its bottom
  /// corners. Taken from the Figma frame.
  static const double headerHeight = 332;
  static const double headerRadius = 40;
  static const double headerBorder = 10;

  /// Content column width on Home. The design centres a fixed-width column
  /// rather than stretching to the screen edges.
  static const double contentWidth = 306;
}
