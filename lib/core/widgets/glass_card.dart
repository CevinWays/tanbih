import 'dart:ui';

import 'package:flutter/material.dart';

import '../styles/styles.dart';

/// The frosted panel the whole design is built from.
///
/// [BackdropFilter] is the expensive part: each one forces the layer beneath
/// it to be read back. The design uses several per screen, so every card is
/// wrapped in a [RepaintBoundary] — the content is static between frames, so
/// the blur is rasterised once instead of on every scroll tick.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: 13,
    ),
    this.radius = AppSpacing.radiusMd,
    this.fill = AppColors.glassFillStrong,
    this.border,
    this.borderWidth = 0,
    this.blur = AppSpacing.glassBlur,
    this.backgroundImage,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color fill;
  final Color? border;
  final double borderWidth;
  final double blur;

  /// Optional ornament drawn behind the content, clipped to the card. Used
  /// for the faint geometric watermark on the prayer rows.
  final ImageProvider? backgroundImage;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: shape,
              border: border == null
                  ? null
                  : Border.all(color: border!, width: borderWidth),
            ),
            child: Stack(
              children: [
                if (backgroundImage != null)
                  Positioned.fill(
                    child: Image(
                      image: backgroundImage!,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: shape,
                    child: Padding(padding: padding, child: child),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
