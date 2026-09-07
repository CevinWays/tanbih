import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../settings/presentation/bloc/locale_cubit.dart';
import '../../../settings/presentation/bloc/theme_cubit.dart';

/// Placeholder shell for the Home screen.
///
/// Phase 1 only proves the wiring: theme tokens, localization, DI, and
/// routing. The real layout (glassmorphism countdown carousel, prayer list,
/// per-prayer theming) lands in Phase 4 from Figma nodes 1:66 / 2002:53285.
@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleCubit>().state;
    final themeMode = context.watch<ThemeCubit>().state;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: AppSpacing.countdownDiameter,
                  height: AppSpacing.countdownDiameter,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.primary,
                  ),
                  child: Center(
                    child: Text(
                      l10n.appName,
                      style: AppTextStyle.wordmark.copyWith(
                        color: AppColors.textOnBrand,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.appTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _LanguageSwitcher(current: locale),
              const SizedBox(height: AppSpacing.lg),
              _ThemeSwitcher(current: themeMode),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher({required this.current});

  final Locale? current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'system', label: Text(l10n.languageFollowSystem)),
        ButtonSegment(value: 'id', label: Text(l10n.languageIndonesian)),
        ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
      ],
      selected: {current?.languageCode ?? 'system'},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        final code = selection.first;
        context.read<LocaleCubit>().setLocale(
          code == 'system' ? null : Locale(code),
        );
      },
    );
  }
}

class _ThemeSwitcher extends StatelessWidget {
  const _ThemeSwitcher({required this.current});

  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<ThemeMode>(
      segments: [
        ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
        ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
        ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
      ],
      selected: {current},
      showSelectedIcon: false,
      onSelectionChanged: (selection) =>
          context.read<ThemeCubit>().setThemeMode(selection.first),
    );
  }
}
