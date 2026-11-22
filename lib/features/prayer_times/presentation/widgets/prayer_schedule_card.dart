import 'package:flutter/material.dart';

import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/prayer_time_entry.dart';
import 'prayer_row_tile.dart';
import 'suhoor_iftaar_row.dart';

/// Today's schedule as one card with hairlines between the rows.
///
/// One [GlassCard], not seven. Each [BackdropFilter] forces a read-back of
/// the layer beneath it, and the previous layout put six of them in the body
/// alone — twice over the budget this app sets for a whole screen.
class PrayerScheduleCard extends StatelessWidget {
  const PrayerScheduleCard({
    required this.entries,
    super.key,
    this.currentSlot,
    this.suhoor,
    this.iftaar,
  });

  /// The prayers, in order. Imsak and sunrise are not rows here.
  final List<PrayerTimeEntry> entries;

  /// The prayer in effect, marked with the accent pill.
  final PrayerSlot? currentSlot;

  /// The fasting pair, shown above the prayers when both are known.
  final DateTime? suhoor;
  final DateTime? iftaar;

  @override
  Widget build(BuildContext context) {
    final fasting = suhoor != null && iftaar != null;

    return GlassCard(
      radius: AppSpacing.radiusLg,
      // The rows carry their own horizontal padding so a highlight can run
      // to the card's edge; the card only pads the ends of the list.
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fasting) ...[
            SuhoorIftaarRow(suhoor: suhoor!, iftaar: iftaar!),
            const _RowDivider(),
          ],
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const _RowDivider(),
            PrayerRowTile(
              entry: entries[i],
              highlighted: entries[i].slot == currentSlot,
            ),
          ],
        ],
      ),
    );
  }
}

/// The rule between two rows, inset so it starts at the label rather than
/// running under the glyph.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: AppSpacing.scheduleDividerInset),
      child: Divider(
        height: AppSpacing.hairline,
        thickness: AppSpacing.hairline,
      ),
    );
  }
}
