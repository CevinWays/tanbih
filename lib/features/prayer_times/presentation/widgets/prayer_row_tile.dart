import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/utils/prayer_slot_x.dart';
import '../../domain/entities/prayer_time_entry.dart';

/// One row of the schedule: marker, icon, name, time.
///
/// The row no longer owns a card. It is rendered inside
/// `PrayerScheduleCard`, which carries the single frosted panel for the whole
/// list — five separate `BackdropFilter`s was five times the budget.
class PrayerRowTile extends StatelessWidget {
  const PrayerRowTile({
    required this.entry,
    super.key,
    this.highlighted = false,
  });

  /// The accent pill, so tests can assert the highlight without reaching for
  /// a colour.
  static const Key markerKey = Key('prayer-row-marker');

  final PrayerTimeEntry entry;

  /// The prayer currently in effect.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timeFormat = DateFormat.jm(
      Localizations.localeOf(context).toString(),
    );
    final label = entry.slot.label(l10n);

    return Semantics(
      selected: highlighted,
      hint: highlighted ? l10n.scheduleCurrentPrayer : null,
      child: ColoredBox(
        color: highlighted ? AppColors.rowHighlight : Colors.transparent,
        // A floor, not a fixed height: the row has to grow with the system
        // font size instead of clipping its own text.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.rowMinHeight),
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Row(
              children: [
                _Marker(visible: highlighted),
                // The exported glyphs are a single dark colour, which
                // disappears against a dark card. Tint them with the theme's
                // text colour so they stay visible in both themes.
                SvgPicture.asset(
                  'assets/icons/${entry.slot.iconAsset}.svg',
                  width: AppSpacing.rowIconSize,
                  height: AppSpacing.rowIconSize,
                  colorFilter: ColorFilter.mode(
                    DefaultTextStyle.of(context).style.color ??
                        AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppSpacing.iconGap),
                Expanded(
                  child: Text(
                    label,
                    style: highlighted
                        ? AppTextStyle.rowLabelActive
                        : AppTextStyle.rowLabel,
                  ),
                ),
                Text(
                  timeFormat.format(entry.time),
                  style: highlighted
                      ? AppTextStyle.prayerTimeActive
                      : AppTextStyle.prayerTime,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The accent pill on the leading edge of the prayer in effect.
///
/// Always occupies its slot, visible or not, so the glyphs of every row stay
/// on the same vertical line.
class _Marker extends StatelessWidget {
  const _Marker({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.lg + AppSpacing.rowMarkerWidth,
      child: visible
          ? Align(
              alignment: Alignment.centerLeft,
              child: Container(
                key: PrayerRowTile.markerKey,
                width: AppSpacing.rowMarkerWidth,
                height: AppSpacing.rowMarkerHeight,
                decoration: BoxDecoration(
                  color: AppColors.brandSolid,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            )
          : null,
    );
  }
}
