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

  /// A 1dp rule. Used for the hairlines between rows of a grouped card.
  static const double hairline = 1;

  /// Gap between a row glyph and the label beside it.
  ///
  /// The design puts 5dp here, which is off the 4dp scale by one — it used to
  /// be written as `xs + 1` in each widget that needed it.
  static const double iconGap = 5;

  /// Glyph size in list rows.
  static const double rowIconSize = 20;

  /// Minimum height of one prayer row inside the grouped schedule.
  ///
  /// A floor, never a fixed height: the row has to grow when the user turns
  /// up the system font size, or the text clips.
  static const double rowMinHeight = 52;

  /// The accent pill marking the prayer currently in effect.
  static const double rowMarkerWidth = 3;
  static const double rowMarkerHeight = 20;

  /// Inset so the rule between rows starts at the label rather than running
  /// under the glyph: lg + marker + icon + the gap after it.
  static const double scheduleDividerInset =
      lg + rowMarkerWidth + rowIconSize + iconGap;

  /// Height of the vertical rule splitting the imsak / iftaar pair.
  static const double pairDividerHeight = 34;

  // Radii — the design leans heavily on very round corners.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 100;

  /// Minimum touch target.
  ///
  /// Material and WCAG both put the floor at 48dp. The icons in this design
  /// are drawn at 20-24dp, so they need padding around them to be reachable
  /// — a 24dp target is hard to hit with a thumb and was, in testing, hard
  /// to hit at all.
  static const double minTouchTarget = 48;

  /// Blur sigma for glassmorphism, matching Figma's `backdrop-blur: 25px`.
  ///
  /// Expensive on low-end Android — keep to roughly three instances per
  /// screen and profile on a physical device.
  static const double glassBlur = 25;

  /// Diameter of the circular countdown on Home.
  static const double countdownDiameter = 172;

  /// The frosted rim of the countdown circle.
  static const double countdownGlassBorder = 16;

  /// Progress arc: how thick it is drawn, and how far inside the rim it sits.
  static const double countdownRingStroke = 6;
  static const double countdownRingInset = 10;

  /// Height of the gradient header on Home, and the radius of its bottom
  /// corners. The Figma frame says 332; the chevrons that needed the extra
  /// room are gone, so the header gives 32dp back to the schedule.
  static const double headerHeight = 300;
  static const double headerRadius = 40;
  static const double headerBorder = 10;

  /// Upper bound on the width of the Home body.
  ///
  /// Phones get the full screen minus [screenPadding]. The design's fixed
  /// 306dp column left 96dp of dead gutter on a 402dp phone — a large part
  /// of why the screen read as sparse — and overflowed outright on a 320dp
  /// one. This cap only bites on tablets and foldables, where a full-bleed
  /// row would run to an unreadable length.
  static const double maxContentWidth = 480;
}
