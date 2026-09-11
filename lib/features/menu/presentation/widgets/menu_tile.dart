import 'package:flutter/material.dart';

import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';

/// One menu entry. [onTap] being null is what marks a feature as not built
/// yet — the tile then renders dimmed with a "coming" badge instead of
/// pretending to be tappable.
class MenuTileData {
  const MenuTileData({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  bool get isAvailable => onTap != null;
}

/// Square tile in the General grid.
class MenuTile extends StatelessWidget {
  const MenuTile({
    required this.data,
    required this.comingSoonLabel,
    super.key,
  });

  final MenuTileData data;
  final String comingSoonLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = data.isAvailable;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GlassCard(
        radius: AppSpacing.radiusLg,
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: data.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data.icon, size: 28, color: AppColors.brandSolid),
            const SizedBox(height: AppSpacing.sm),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!enabled) ...[
              const SizedBox(height: AppSpacing.xxs),
              _ComingBadge(label: comingSoonLabel),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-width row in the Other section.
class MenuRow extends StatelessWidget {
  const MenuRow({required this.data, required this.comingSoonLabel, super.key});

  final MenuTileData data;
  final String comingSoonLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = data.isAvailable;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GlassCard(
        radius: AppSpacing.radiusLg,
        onTap: data.onTap,
        child: Row(
          children: [
            Icon(data.icon, size: 24, color: AppColors.brandSolid),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.label, style: AppTextStyle.rowLabel),
                  if (data.subtitle != null)
                    Text(data.subtitle!, style: AppTextStyle.bodySmall),
                ],
              ),
            ),
            if (enabled)
              Icon(
                Icons.chevron_right,
                color: DefaultTextStyle.of(
                  context,
                ).style.color?.withValues(alpha: 0.6),
              )
            else
              _ComingBadge(label: comingSoonLabel),
          ],
        ),
      ),
    );
  }
}

class _ComingBadge extends StatelessWidget {
  const _ComingBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandSolid.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyle.bodySmall.copyWith(
          fontSize: 10,
          color: AppColors.brandTeal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
