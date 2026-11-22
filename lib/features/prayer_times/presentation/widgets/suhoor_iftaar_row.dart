import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';

/// The imsak / iftaar pair at the top of the schedule.
///
/// These two are what a fasting person actually looks for, so the design
/// lifts them above the list of prayers. They sit inside the same card as
/// the rows rather than in one of their own: the frosted panel is expensive
/// and this is the same list.
class SuhoorIftaarRow extends StatelessWidget {
  const SuhoorIftaarRow({
    required this.suhoor,
    required this.iftaar,
    super.key,
  });

  final DateTime suhoor;
  final DateTime iftaar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = DateFormat.jm(Localizations.localeOf(context).toString());

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _Side(
              // Imsak is the pre-dawn moment, so it shares Fajr's crescent —
              // the same mapping the schedule rows use.
              icon: 'prayer_fajr',
              label: l10n.suhoorLabel,
              time: format.format(suhoor),
              alignment: CrossAxisAlignment.start,
            ),
          ),
          Container(
            width: AppSpacing.hairline,
            height: AppSpacing.pairDividerHeight,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            // From the theme, not a constant: the light hairline is all but
            // invisible on a dark card.
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: _Side(
              icon: 'prayer_maghrib',
              label: l10n.iftaarLabel,
              time: format.format(iftaar),
              alignment: CrossAxisAlignment.end,
              iconTrailing: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.icon,
    required this.label,
    required this.time,
    required this.alignment,
    this.iconTrailing = false,
  });

  final String icon;
  final String label;
  final String time;
  final CrossAxisAlignment alignment;
  final bool iconTrailing;

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyle.rowLabel),
        Text(time, style: AppTextStyle.pairTime),
      ],
    );

    final glyph = SvgPicture.asset(
      'assets/icons/$icon.svg',
      width: AppSpacing.xxl,
      height: AppSpacing.xxl,
      colorFilter: ColorFilter.mode(
        DefaultTextStyle.of(context).style.color ?? AppColors.textPrimary,
        BlendMode.srcIn,
      ),
    );

    return Row(
      mainAxisAlignment: iconTrailing
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: iconTrailing
          ? [Flexible(child: text), const SizedBox(width: AppSpacing.md), glyph]
          : [
              glyph,
              const SizedBox(width: AppSpacing.md),
              Flexible(child: text),
            ],
    );
  }
}
