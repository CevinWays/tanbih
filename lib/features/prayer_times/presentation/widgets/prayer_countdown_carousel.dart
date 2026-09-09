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
  late final PageController _controller;
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = _initialPage;
    _controller = PageController(initialPage: _page);
  }

  int get _initialPage {
    final index = widget.entries.indexWhere((e) => e.slot == widget.nextSlot);
    return index < 0 ? 0 : index;
  }

  @override
  void didUpdateWidget(PrayerCountdownCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow the countdown when it rolls over to the next prayer, but only
    // while the user is sitting on the page that just expired — never yank
    // the view out from under someone who is browsing.
    if (widget.nextSlot != oldWidget.nextSlot &&
        _page ==
            oldWidget.entries.indexWhere((e) => e.slot == oldWidget.nextSlot)) {
      final target = _initialPage;
      if (target != _page && _controller.hasClients) {
        _controller.animateToPage(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final target = (_page + delta).clamp(0, widget.entries.length - 1);
    if (target == _page) return;
    _controller.animateToPage(
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

    return SizedBox(
      height: AppSpacing.countdownDiameter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassIconButton(
            assetName: 'chevron_right',
            semanticLabel: l10n.previousPrayer,
            flipHorizontally: true,
            onPressed: _page > 0 ? () => _step(-1) : null,
          ),
          const SizedBox(width: AppSpacing.huge),
          SizedBox(
            width: AppSpacing.countdownDiameter,
            height: AppSpacing.countdownDiameter,
            child: PageView.builder(
              controller: _controller,
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
          const SizedBox(width: AppSpacing.huge),
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
