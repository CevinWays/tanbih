import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/settings_scaffold.dart';

/// Credits and licences.
///
/// Not a courtesy page. The bundled fonts are OFL and the city coordinates
/// come from OpenStreetMap under ODbL; both licences require attribution
/// where users can see it, so this screen is a condition of shipping those
/// assets rather than a nicety.
@RoutePage()
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.aboutTitle,
      children: [
        Center(
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/icons/tanbih_mark.svg',
                width: 72,
                height: 72,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.appName, style: AppTextStyle.h2),
              Text(l10n.aboutTagline, style: AppTextStyle.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              const _VersionLabel(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        _Section(title: l10n.aboutPrivacyTitle, body: l10n.aboutPrivacyBody),
        _Section(title: l10n.aboutCalcTitle, body: l10n.aboutCalcBody),

        const SizedBox(height: AppSpacing.lg),
        Text(l10n.aboutCreditsTitle, style: AppTextStyle.h3),
        const SizedBox(height: AppSpacing.md),

        _Section(title: l10n.aboutAdhanTitle, body: l10n.aboutAdhanBody),
        _Section(title: l10n.aboutFontsTitle, body: l10n.aboutFontsBody),
        _Section(title: l10n.aboutCitiesTitle, body: l10n.aboutCitiesBody),
      ],
    );
  }
}

/// Reads the version from the package rather than a constant, so it cannot
/// drift from what was actually built.
class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox(height: 18);

        return Text(
          context.l10n.aboutVersion('${info.version} (${info.buildNumber})'),
          style: AppTextStyle.bodySmall,
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        radius: AppSpacing.radiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyle.rowLabel),
            const SizedBox(height: AppSpacing.xxs),
            Text(body, style: AppTextStyle.bodySmall),
          ],
        ),
      ),
    );
  }
}
