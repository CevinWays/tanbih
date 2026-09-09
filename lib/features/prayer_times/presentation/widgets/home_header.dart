import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../domain/entities/hijri_date.dart';

/// The gradient panel behind the countdown: location, actions, and the two
/// calendars.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.locationLabel,
    required this.date,
    required this.hijriDate,
    required this.child,
    super.key,
    this.onLocationTap,
    this.onSettingsTap,
    this.onMenuTap,
    this.isRefreshingLocation = false,
  });

  final String locationLabel;

  /// Null until the first schedule resolves.
  final DateTime? date;
  final HijriDate? hijriDate;

  /// The countdown carousel, positioned inside the gradient.
  final Widget child;

  final VoidCallback? onLocationTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onMenuTap;
  final bool isRefreshingLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final gregorian = date == null
        ? null
        : DateFormat('EEEE, d MMM yyyy', locale).format(date!);

    return Container(
      height: AppSpacing.headerHeight,
      decoration: BoxDecoration(
        gradient: AppGradients.primaryVertical,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.headerRadius),
        ),
        border: Border.all(
          color: AppColors.headerEdge,
          width: AppSpacing.headerBorder,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _LocationChip(
                      label: locationLabel,
                      isRefreshing: isRefreshingLocation,
                      onTap: onLocationTap,
                    ),
                  ),
                  _HeaderAction(
                    assetName: 'settings',
                    semanticLabel: l10n.openSettings,
                    onPressed: onSettingsTap,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _HeaderAction(
                    assetName: 'menu',
                    semanticLabel: l10n.openMenu,
                    onPressed: onMenuTap,
                  ),
                ],
              ),
              Expanded(child: Center(child: child)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (gregorian != null)
                    Text(gregorian, style: AppTextStyle.onHeaderCaption),
                  if (hijriDate != null)
                    Text(
                      '${hijriDate!.day} ${hijriDate!.monthName} '
                      '${hijriDate!.year}',
                      style: AppTextStyle.onHeaderCaption,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.label,
    required this.isRefreshing,
    this.onTap,
  });

  final String label;
  final bool isRefreshing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/location_pin.svg',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: AppSpacing.xs + 1),
            Flexible(
              child: Text(
                label,
                style: AppTextStyle.onHeaderLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRefreshing) ...[
              const SizedBox(width: AppSpacing.sm),
              // A quiet hint that a fresh fix is on the way — the cached
              // location is already usable, so this must not block anything.
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.assetName,
    required this.semanticLabel,
    this.onPressed,
  });

  final String assetName;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onPressed,
        radius: AppSpacing.xl,
        child: SvgPicture.asset(
          'assets/icons/$assetName.svg',
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}
