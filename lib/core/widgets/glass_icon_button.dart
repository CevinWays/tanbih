import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../styles/styles.dart';

/// Round translucent button — the chevrons flanking the countdown.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.assetName,
    required this.semanticLabel,
    super.key,
    this.onPressed,
    this.iconSize = 12,
    this.flipHorizontally = false,
    this.fill = AppColors.glassFillStrong,
    this.border = AppColors.glassBorderStrong,
  });

  final String assetName;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final double iconSize;

  /// The design ships a single chevron asset; the left button mirrors it
  /// rather than shipping a second, identical-but-flipped file.
  final bool flipHorizontally;

  final Color fill;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      'assets/icons/$assetName.svg',
      width: iconSize,
      height: iconSize,
    );

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSpacing.glassBlur,
            sigmaY: AppSpacing.glassBlur,
          ),
          child: Material(
            color: fill,
            shape: CircleBorder(side: BorderSide(color: border, width: 5)),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: SizedBox(
                // The design draws a 26dp button; the target underneath it
                // is padded out to the 48dp floor.
                width: AppSpacing.minTouchTarget,
                height: AppSpacing.minTouchTarget,
                child: Center(
                  child: flipHorizontally
                      ? Transform.flip(flipX: true, child: icon)
                      : icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
