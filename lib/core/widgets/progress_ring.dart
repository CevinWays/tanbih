import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../styles/styles.dart';

/// A circular track with an arc drawn over it.
///
/// Replaces the decorative ring SVG the countdown used to stack behind its
/// text: that asset was a single 10%-white circle, which is exactly what the
/// track stroke here draws — keeping both would have painted the same circle
/// twice at slightly different radii and read as a seam.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    super.key,
    this.stroke = AppSpacing.countdownRingStroke,
    this.child,
  });

  /// 0 at the previous prayer, 1 at the next. Values outside are clamped.
  final double progress;

  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ProgressRingPainter(
        progress: progress.clamp(0.0, 1.0),
        stroke: stroke,
        track: AppColors.glassBorder,
        arc: Colors.white,
      ),
      child: child,
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.stroke,
    required this.track,
    required this.arc,
  });

  final double progress;
  final double stroke;
  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    if (radius <= 0) return;

    final centre = Offset(size.width / 2, size.height / 2);
    final bounds = Rect.fromCircle(center: centre, radius: radius);

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    if (progress <= 0) return;

    canvas.drawArc(
      bounds,
      // Twelve o'clock, so the ring reads like a clock face.
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = arc,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress ||
      old.stroke != stroke ||
      old.track != track ||
      old.arc != arc;
}
