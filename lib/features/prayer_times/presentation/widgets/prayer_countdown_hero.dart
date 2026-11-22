import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/utils/countdown_format.dart';
import '../../../../core/utils/prayer_slot_x.dart';
import '../../../../core/widgets/progress_ring.dart';
import '../bloc/next_prayer_countdown_cubit.dart';

/// The circular hero on Home: which prayer is next, how long until it, and
/// when it falls — inside a ring that fills as the time approaches.
///
/// It subscribes to the countdown itself rather than taking the values as
/// arguments. Reading the cubit higher up meant the whole screen rebuilt
/// once a second, which forced this widget's [BackdropFilter] to be
/// re-recorded with it. Everything that ticks is behind a [BlocSelector]
/// *inside* the blur, so the expensive layer is built once.
class PrayerCountdownHero extends StatelessWidget {
  const PrayerCountdownHero({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: AppSpacing.countdownDiameter,
        height: AppSpacing.countdownDiameter,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppSpacing.glassBlur,
              sigmaY: AppSpacing.glassBlur,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassFill,
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: AppSpacing.countdownGlassBorder,
                ),
              ),
              // The ring fills the rim; the text is inset far enough inside
              // it that a wide value like "5:12:44" cannot run under the arc.
              child: const Stack(
                fit: StackFit.expand,
                children: [
                  _Ring(),
                  Padding(
                    padding: EdgeInsets.all(
                      AppSpacing.countdownRingStroke +
                          AppSpacing.countdownRingInset,
                    ),
                    child: _Face(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocSelector<NextPrayerCountdownCubit, CountdownState, double>(
        // Quantised: the arc moves imperceptibly between ticks on a
        // multi-hour window, so repainting it every second buys nothing.
        selector: (state) => (state.progress * 1000).round() / 1000,
        builder: (context, progress) =>
            ProgressRing(progress: progress, child: const SizedBox.expand()),
      ),
    );
  }
}

/// The three lines of text, which are all that change on most ticks.
class _Face extends StatelessWidget {
  const _Face();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final clock = DateFormat.jm(locale);

    return BlocBuilder<NextPrayerCountdownCubit, CountdownState>(
      builder: (context, state) {
        if (!state.isActive || state.slot == null) {
          return const SizedBox.shrink();
        }

        final name = state.slot!.label(l10n);
        final arrived = state.phase == CountdownPhase.arrived;
        final remaining = state.remaining;

        final value = arrived || remaining == null
            ? l10n.prayerTimeNow
            : formatCountdown(remaining);

        return Semantics(
          liveRegion: true,
          label: arrived || remaining == null
              ? '$name — ${l10n.prayerTimeNow}'
              : l10n.countdownSemantics(
                  name,
                  countdownSemanticDuration(l10n, remaining),
                ),
          excludeSemantics: true,
          // Scaled as one block rather than line by line, so the three lines
          // keep their relative sizes. The circle is a hard boundary in both
          // directions: "5:12:44" is three glyphs wider than "39:07", and at
          // a raised system font size the stack is taller than the circle.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, maxLines: 1, style: AppTextStyle.countdownPrayer),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  maxLines: 1,
                  style: arrived
                      ? AppTextStyle.countdownPrayer
                      : AppTextStyle.countdownTimer,
                ),
                if (state.slotTime != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    clock.format(state.slotTime!),
                    maxLines: 1,
                    style: AppTextStyle.countdownTarget,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
