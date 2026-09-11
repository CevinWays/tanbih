import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/utils/prayer_slot_x.dart';
import '../../../../core/widgets/glass_icon_button.dart';
import '../../domain/entities/prayer_time_entry.dart';

/// The circular hero on Home: swipe or tap the chevrons to move between
/// prayers.
///
/// The prayer the user is counting down to shows the remaining time; every
/// other page shows that prayer's clock time, because "remaining" is
/// meaningless for a prayer that already passed or is two steps away.
class PrayerCountdownCarousel extends StatefulWidget {
  const PrayerCountdownCarousel({
    required this.entries,
    required this.nextSlot,
    required this.remaining,
    super.key,
  });

  /// Prayer rows only — imsak and sunrise are not counted down to.
  final List<PrayerTimeEntry> entries;

  final PrayerSlot? nextSlot;
  final Duration? remaining;

  @override
  State<PrayerCountdownCarousel> createState() =>
      _PrayerCountdownCarouselState();
}

class _PrayerCountdownCarouselState extends State<PrayerCountdownCarousel> {
  /// Created only once there is something to page through.
  ///
  /// The schedule arrives after the first build, so on startup this widget
  /// renders an empty placeholder with no PageView at all. Creating the
  /// controller eagerly meant it had no clients when the countdown target
  /// finally appeared, and the jump to the next prayer silently did nothing
  /// — the carousel sat on a prayer that had already passed. Building it
  /// when the entries land lets `initialPage` do the work instead.
  PageController? _controller;
  int _page = 0;

  int get _initialPage {
    final index = widget.entries.indexWhere((e) => e.slot == widget.nextSlot);
    return index < 0 ? 0 : index;
  }

  @override
  void didUpdateWidget(PrayerCountdownCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nextSlot == oldWidget.nextSlot) return;

    // The schedule and the countdown arrive on separate frames, so the first
    // build has no target yet and lands on page zero. Once a target appears,
    // move to it — otherwise the carousel sits on a prayer that has already
    // passed, which is exactly what it did on the first device run.
    final hadNoTarget = oldWidget.nextSlot == null;

    // After that, follow a rollover only while the user is sitting on the
    // page that just expired; never yank the view away from someone who is
    // browsing other prayers.
    final sittingOnExpired =
        _page ==
        oldWidget.entries.indexWhere((e) => e.slot == oldWidget.nextSlot);

    if (!hadNoTarget && !sittingOnExpired) return;

    final target = _initialPage;
    if (target == _page) return;

    final controller = _controller;
    if (controller == null || !controller.hasClients) {
      // No viewport yet: remember the target so the PageView is built on it.
      setState(() => _page = target);
      return;
    }

    controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final target = (_page + delta).clamp(0, widget.entries.length - 1);
    if (target == _page) return;
    _controller?.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (widget.entries.isEmpty) {
      return const SizedBox(height: AppSpacing.countdownDiameter);
    }

    // First build with real entries: start on the prayer being counted down
    // to rather than on whatever happens to be first.
    if (_controller == null) {
      _page = _initialPage;
      _controller = PageController(initialPage: _page);
    }

    return SizedBox(
      height: AppSpacing.countdownDiameter,
      // Space the chevrons against the edges rather than using fixed gaps.
      // The gaps in the design assume a 26dp button; padding those out to a
      // reachable 48dp made a fixed-gap row overflow the screen.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassIconButton(
            assetName: 'chevron_right',
            semanticLabel: l10n.previousPrayer,
            flipHorizontally: true,
            onPressed: _page > 0 ? () => _step(-1) : null,
          ),
          SizedBox(
            width: AppSpacing.countdownDiameter,
            height: AppSpacing.countdownDiameter,
            child: PageView.builder(
              controller: _controller,
              key: ValueKey(widget.entries.length),
              itemCount: widget.entries.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) {
                final entry = widget.entries[index];
                return _CountdownFace(
                  entry: entry,
                  remaining: entry.slot == widget.nextSlot
                      ? widget.remaining
                      : null,
                );
              },
            ),
          ),
          GlassIconButton(
            assetName: 'chevron_right',
            semanticLabel: l10n.nextPrayerAction,
            fill: AppColors.glassFill,
            border: AppColors.glassBorder,
            onPressed: _page < widget.entries.length - 1
                ? () => _step(1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _CountdownFace extends StatelessWidget {
  const _CountdownFace({required this.entry, this.remaining});

  final PrayerTimeEntry entry;

  /// Null on every page except the prayer being counted down to.
  final Duration? remaining;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    final value = remaining == null
        ? DateFormat.jm(locale).format(entry.time)
        : formatRemaining(l10n, remaining!);

    return RepaintBoundary(
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
              border: Border.all(color: AppColors.glassBorder, width: 16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/countdown_ring.svg',
                  width: AppSpacing.countdownRingDiameter,
                  height: AppSpacing.countdownRingDiameter,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/praying_person.svg',
                      width: 32,
                      height: 32,
                    ),
                    Text(
                      entry.slot.label(l10n),
                      style: AppTextStyle.countdownPrayer,
                    ),
                    Text(value, style: AppTextStyle.countdownValue),
                    Text(
                      remaining == null ? '' : l10n.remainingLabel,
                      style: AppTextStyle.countdownCaption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
