import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/routes/app_router.gr.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/themed_chevron.dart';
import '../../domain/entities/qibla_summary.dart';
import '../bloc/qibla_summary_cubit.dart';

/// The compact qibla line on Home: bearing and distance, tapping opens the
/// full compass.
///
/// Reads its own state rather than being handed values, so Home does not
/// have to thread qibla data through its body.
class QiblaSummaryRow extends StatelessWidget {
  const QiblaSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<QiblaSummaryCubit, QiblaSummaryState>(
      builder: (context, state) {
        // Nothing to say. Home already explains a location failure; a second
        // apology underneath it is just noise.
        if (state.status == QiblaSummaryStatus.failure) {
          return const SizedBox.shrink();
        }

        final summary = state.summary;

        return GlassCard(
          radius: AppSpacing.radiusMd,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          // Not tappable until there is a bearing to show on the other side.
          onTap: summary == null
              ? null
              : () => context.router.push(const QiblaRoute()),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
            ),
            child: Row(
              children: [
                // The Kaaba SVG is a tall illustration drawn for the compass
                // dial; at row size it is an unreadable smudge. This is the
                // glyph the menu already uses for the qibla.
                const Icon(Icons.explore_outlined, size: AppSpacing.xxl),
                const SizedBox(width: AppSpacing.iconGap),
                Text(l10n.qiblaShort, style: AppTextStyle.rowLabel),
                const SizedBox(width: AppSpacing.md),
                // The value is the part worth reading, so it gets the room
                // that is left rather than an even split with the label.
                Expanded(
                  child: Text(
                    summary == null
                        ? l10n.qiblaSummaryPending
                        : _value(context, summary),
                    style: AppTextStyle.rowValue,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                const ThemedChevron(),
              ],
            ),
          ),
        );
      },
    );
  }

  String _value(BuildContext context, QiblaSummary summary) {
    final l10n = context.l10n;

    // Rounded to whole kilometres here, then grouped — gen-l10n's number
    // placeholders cannot express that order, so the distance crosses into
    // the ARB message as an already-formatted string.
    final kilometres = summary.distanceKm.round();
    if (kilometres < 1) return l10n.qiblaAtKaaba;

    final locale = Localizations.localeOf(context).toString();
    return l10n.qiblaSummaryValue(
      summary.bearingDegrees.round(),
      NumberFormat.decimalPattern(locale).format(kilometres),
    );
  }
}
