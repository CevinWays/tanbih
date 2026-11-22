import 'package:flutter/material.dart';

import '../styles/styles.dart';
import 'themed_chevron.dart';
import 'glass_card.dart';

/// One settings row: title, optional explanation, and a trailing control.
///
/// The design uses the same row for navigation, toggles, and checks, so the
/// trailing widget is the only thing that varies.
class SettingTile extends StatelessWidget {
  const SettingTile({
    required this.title,
    super.key,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  /// Navigation row: shows the current value under the title and a chevron.
  factory SettingTile.navigation({
    required String title,
    required VoidCallback? onTap,
    String? subtitle,
    String? value,
    bool enabled = true,
    Key? key,
  }) => SettingTile(
    key: key,
    title: title,
    subtitle: subtitle,
    value: value,
    enabled: enabled,
    onTap: onTap,
    trailing: const ThemedChevron(),
  );

  /// Toggle row. Tapping anywhere on the row flips it, not just the switch —
  /// the whole row is the target in the design.
  factory SettingTile.toggle({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? subtitle,
    Key? key,
  }) => SettingTile(
    key: key,
    title: title,
    subtitle: subtitle,
    enabled: onChanged != null,
    onTap: onChanged == null ? null : () => onChanged(!value),
    trailing: Switch.adaptive(value: value, onChanged: onChanged),
  );

  final String title;
  final String? subtitle;

  /// Current selection, shown under the title.
  final String? value;

  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final subtitleText = value ?? subtitle;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: GlassCard(
          radius: AppSpacing.radiusMd,
          onTap: enabled ? onTap : null,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.rowLabel),
                    if (subtitleText != null && subtitleText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitleText,
                          style: AppTextStyle.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Chevron that follows the theme's text colour.
///
/// A fixed grey was invisible against a dark card.
/// Section heading between groups of rows.
class SettingSectionHeader extends StatelessWidget {
  const SettingSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.sm),
      child: Text(title, style: AppTextStyle.h3.copyWith(fontSize: 16)),
    );
  }
}
