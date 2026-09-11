import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../widgets/menu_section.dart';
import '../widgets/menu_tile.dart';

/// Hub for everything that is not the daily schedule.
///
/// Only Qibla is built in this iteration; the rest are shown but marked as
/// coming, so the roadmap is visible without pretending the features exist.
@RoutePage()
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Column(
        children: [
          _MenuHeader(title: l10n.menuTitle),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.huge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MenuSection(title: l10n.menuGeneral),
                  const SizedBox(height: AppSpacing.md),
                  _GeneralGrid(l10n: l10n),
                  const SizedBox(height: AppSpacing.xxl),
                  MenuSection(title: l10n.menuOther),
                  const SizedBox(height: AppSpacing.md),
                  _OtherList(l10n: l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralGrid extends StatelessWidget {
  const _GeneralGrid({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = <MenuTileData>[
      MenuTileData(icon: Icons.explore_outlined, label: l10n.menuQibla),
      MenuTileData(icon: Icons.menu_book_outlined, label: l10n.menuDuas),
      MenuTileData(icon: Icons.list_alt_outlined, label: l10n.menuPrayerGuide),
      MenuTileData(icon: Icons.water_drop_outlined, label: l10n.menuWuduGuide),
      MenuTileData(icon: Icons.adjust_outlined, label: l10n.menuTasbih),
      MenuTileData(
        icon: Icons.calendar_month_outlined,
        label: l10n.menuCalendar,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.95,
      children: [
        for (final item in items)
          MenuTile(data: item, comingSoonLabel: l10n.menuComingSoon),
      ],
    );
  }
}

class _OtherList extends StatelessWidget {
  const _OtherList({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // These all open something outside the app (a mail client, the store,
    // a share sheet), which is wired up in the release phase. Until then
    // they carry the same "coming" marker as the unbuilt features rather
    // than silently doing nothing when tapped.
    final rows = <MenuTileData>[
      MenuTileData(
        icon: Icons.mail_outline,
        label: l10n.menuFeedback,
        subtitle: l10n.menuFeedbackSubtitle,
      ),
      MenuTileData(
        icon: Icons.star_outline,
        label: l10n.menuRateUs,
        subtitle: l10n.menuRateUsSubtitle,
      ),
      MenuTileData(
        icon: Icons.share_outlined,
        label: l10n.menuShareApp,
        subtitle: l10n.menuShareAppSubtitle,
      ),
      MenuTileData(
        icon: Icons.favorite_outline,
        label: l10n.menuFinancialSupport,
        subtitle: l10n.menuFinancialSupportSubtitle,
      ),
    ];

    return Column(
      children: [
        for (final row in rows) ...[
          MenuRow(data: row, comingSoonLabel: l10n.menuComingSoon),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryVertical,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.headerRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Row(
            children: [
              const BackButton(color: Colors.white),
              Text(title, style: AppTextStyle.onHeaderLabel),
            ],
          ),
        ),
      ),
    );
  }
}
