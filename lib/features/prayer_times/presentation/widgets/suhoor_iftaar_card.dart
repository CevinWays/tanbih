import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';

/// The imsak / maghrib pair at the top of the schedule.
///
/// These two are what a fasting person actually looks for, so the design
/// lifts them out of the list into their own card.
class SuhoorIftaarCard extends StatelessWidget {
  const SuhoorIftaarCard({
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

    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: _Side(
              icon: 'speaker_suhoor',
              label: l10n.suhoorLabel,
              time: format.format(suhoor),
              alignment: CrossAxisAlignment.start,
            ),
          ),
          Container(
            width: 1,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: AppColors.divider,
          ),
          Expanded(
            child: _Side(
              icon: 'speaker_on',
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
        Text(
          time,
          style: AppTextStyle.rowLabel.copyWith(
            fontSize: 16,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );

    final glyph = SvgPicture.asset(
      'assets/icons/$icon.svg',
      width: 24,
      height: 24,
    );

    return Row(
      mainAxisAlignment: iconTrailing
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: iconTrailing
          ? [Flexible(child: text), const SizedBox(width: AppSpacing.lg), glyph]
          : [
              glyph,
              const SizedBox(width: AppSpacing.lg),
              Flexible(child: text),
            ],
    );
  }
}
