import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/utils/prayer_slot_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/prayer_time_entry.dart';

/// One row of the schedule: icon, name, time, notification toggle.
class PrayerRowTile extends StatelessWidget {
  const PrayerRowTile({
    required this.entry,
    required this.notificationEnabled,
    super.key,
    this.onToggleNotification,
    this.highlighted = false,
  });

  final PrayerTimeEntry entry;
  final bool notificationEnabled;
  final VoidCallback? onToggleNotification;

  /// The prayer currently in effect gets a slightly stronger fill.
  final bool highlighted;

  static const AssetImage _watermark = AssetImage(
    'assets/images/row_watermark.png',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timeFormat = DateFormat.jm(
      Localizations.localeOf(context).toString(),
    );

    return GlassCard(
      radius: AppSpacing.radiusSm + 2,
      backgroundImage: _watermark,
      fill: highlighted ? AppColors.glassFill : AppColors.glassFillStrong,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/${entry.slot.iconAsset}.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: AppSpacing.xs + 1),
          Expanded(
            child: Text(entry.slot.label(l10n), style: AppTextStyle.rowLabel),
          ),
          Text(timeFormat.format(entry.time), style: AppTextStyle.prayerTime),
          const SizedBox(width: AppSpacing.xl),
          _NotificationToggle(
            enabled: notificationEnabled,
            onPressed: onToggleNotification,
            prayerName: entry.slot.label(l10n),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.enabled,
    required this.prayerName,
    this.onPressed,
  });

  final bool enabled;
  final String prayerName;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      button: true,
      toggled: enabled,
      label:
          '$prayerName — '
          '${enabled ? l10n.notificationOn : l10n.notificationOff}',
      child: InkResponse(
        onTap: onPressed,
        radius: AppSpacing.xl,
        child: SvgPicture.asset(
          enabled
              ? 'assets/icons/speaker_on.svg'
              : 'assets/icons/speaker_muted.svg',
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}
