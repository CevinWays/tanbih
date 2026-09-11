import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/styles/styles.dart';

/// The rotating dial.
///
/// The rose turns against the heading so the cardinal letters stay pointing
/// at the real world, and the Kaaba marker rides at the qibla bearing. The
/// fixed triangle at the top is the phone itself — line the marker up with
/// it and you are facing Makkah.
class QiblaCompass extends StatelessWidget {
  const QiblaCompass({
    required this.headingDegrees,
    required this.relativeBearingDegrees,
    required this.isFacing,
    super.key,
  });

  /// Null when there is no sensor; the dial then sits still at north.
  final double? headingDegrees;

  /// Where the Kaaba is, relative to the top of the screen.
  final double? relativeBearingDegrees;

  final bool isFacing;

  static const double _size = 260;

  @override
  Widget build(BuildContext context) {
    final heading = headingDegrees ?? 0;
    final relative = relativeBearingDegrees;

    return SizedBox(
      width: _size,
      height: _size + 40,
      child: Column(
        children: [
          // The pointer belongs to the device, not the dial, so it never
          // rotates.
          Icon(
            Icons.arrow_drop_up,
            size: 40,
            color: isFacing ? AppColors.brandMint : Colors.white,
          ),
          SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Turning the rose by minus the heading keeps N pointing at
                // magnetic-corrected true north as the phone turns.
                Transform.rotate(
                  angle: -heading * math.pi / 180,
                  child: CustomPaint(
                    size: const Size(_size, _size),
                    painter: _RosePainter(isFacing: isFacing),
                  ),
                ),
                if (relative != null)
                  Transform.rotate(
                    angle: relative * math.pi / 180,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: isFacing
                                ? AppColors.brandMint
                                : AppColors.glassFillStrong,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.navigation,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                SvgPicture.asset(
                  'assets/icons/kaaba.svg',
                  width: 64,
                  height: 64,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RosePainter extends CustomPainter {
  const _RosePainter({required this.isFacing});

  final bool isFacing;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: isFacing ? 0.9 : 0.45);

    canvas
      ..drawCircle(centre, radius - 2, ring)
      ..drawCircle(centre, radius * 0.78, ring)
      ..drawCircle(
        centre,
        radius * 0.55,
        Paint()..color = Colors.white.withValues(alpha: 0.12),
      );

    final tick = Paint()
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.5);

    // A tick every 15 degrees, longer on the cardinals.
    for (var degrees = 0; degrees < 360; degrees += 15) {
      final isCardinal = degrees % 90 == 0;
      final angle = (degrees - 90) * math.pi / 180;
      final outer = radius - 6;
      final inner = outer - (isCardinal ? 14 : 7);

      canvas.drawLine(
        centre + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        centre + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        tick,
      );
    }

    const labels = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    for (final entry in labels.entries) {
      final angle = (entry.key - 90) * math.pi / 180;
      final distance = radius * 0.62;
      final painter = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: AppTextStyle.label.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        centre +
            Offset(math.cos(angle) * distance, math.sin(angle) * distance) -
            Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_RosePainter oldDelegate) =>
      oldDelegate.isFacing != isFacing;
}
