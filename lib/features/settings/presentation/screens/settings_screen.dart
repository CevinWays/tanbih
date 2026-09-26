import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/routes/app_router.gr.dart';
import '../../../../core/widgets/option_picker_sheet.dart';
import '../../../../core/widgets/setting_tile.dart';
import '../../../../core/widgets/settings_scaffold.dart';
import '../bloc/locale_cubit.dart';
import '../bloc/theme_cubit.dart';

/// Settings hub.
///
/// Rows for features that are not built yet are shown but disabled, so the
/// screen matches the design without offering controls that do nothing.
@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleCubit>().state;
    final themeMode = context.watch<ThemeCubit>().state;

    return SettingsScaffold(
      title: l10n.settingsTitle,
      children: [
        SettingTile.navigation(
          title: l10n.settingsPrayerTimes,
          subtitle: l10n.settingsPrayerTimesSubtitle,
          onTap: () => context.router.push(const PrayerTimesSettingsRoute()),
        ),
        SettingTile.navigation(
          title: l10n.settingsLocation,
          subtitle: l10n.settingsLocationSubtitle,
          onTap: () => context.router.push(const LocationSettingsRoute()),
        ),
        SettingTile.navigation(
          title: l10n.settingsNotification,
          subtitle: l10n.settingsNotificationSubtitle,
          onTap: () => context.router.push(const NotificationSettingsRoute()),
        ),
        // The Fajr alarm lives inside the notification screen, which is
        // where its permissions and sound already are.
        SettingTile.navigation(
          title: l10n.settingsFajrAlarm,
          subtitle: l10n.settingsFajrAlarmSubtitle,
          onTap: () => context.router.push(const NotificationSettingsRoute()),
        ),
        SettingTile.navigation(
          title: l10n.settingsSilent,
          subtitle: l10n.settingsSilentSubtitle,
          enabled: false,
          onTap: null,
        ),
        SettingTile.navigation(
          title: l10n.settingsHijri,
          subtitle: l10n.settingsHijriSubtitle,
          onTap: () => context.router.push(const HijriSettingsRoute()),
        ),
        // A binary switch cannot express "follow the system", which is the
        // default. On a phone in dark mode it read as off while the app was
        // plainly dark — so this is a three-way choice, like Language.
        SettingTile.navigation(
          title: l10n.themeTitle,
          value: _themeLabel(l10n, themeMode),
          onTap: () => _pickTheme(context, l10n, themeMode),
        ),
        SettingTile.navigation(
          title: l10n.settingsLanguage,
          value: _languageLabel(l10n, locale),
          onTap: () => _pickLanguage(context, l10n, locale),
        ),
        SettingTile.navigation(
          title: l10n.aboutTitle,
          onTap: () => context.router.push(const AboutRoute()),
        ),
      ],
    );
  }

  static String _themeLabel(AppLocalizations l10n, ThemeMode mode) =>
      switch (mode) {
        ThemeMode.light => l10n.themeLight,
        ThemeMode.dark => l10n.themeDark,
        ThemeMode.system => l10n.themeSystem,
      };

  Future<void> _pickTheme(
    BuildContext context,
    AppLocalizations l10n,
    ThemeMode current,
  ) async {
    final cubit = context.read<ThemeCubit>();

    final choice = await OptionPickerSheet.show<ThemeMode>(
      context: context,
      title: l10n.themeTitle,
      options: ThemeMode.values,
      selected: current,
      labelOf: (mode) => _themeLabel(l10n, mode),
    );
    if (choice != null) await cubit.setThemeMode(choice);
  }

  static String _languageLabel(AppLocalizations l10n, Locale? locale) =>
      switch (locale?.languageCode) {
        'id' => l10n.languageIndonesian,
        'en' => l10n.languageEnglish,
        _ => l10n.languageFollowSystem,
      };

  Future<void> _pickLanguage(
    BuildContext context,
    AppLocalizations l10n,
    Locale? current,
  ) async {
    // 'system' is a real choice, not the absence of one, so it is offered
    // alongside the two languages rather than hidden behind a reset.
    const options = ['system', 'id', 'en'];
    final cubit = context.read<LocaleCubit>();

    final choice = await OptionPickerSheet.show<String>(
      context: context,
      title: l10n.settingsLanguage,
      options: options,
      selected: current?.languageCode ?? 'system',
      labelOf: (code) => switch (code) {
        'id' => l10n.languageIndonesian,
        'en' => l10n.languageEnglish,
        _ => l10n.languageFollowSystem,
      },
    );
    if (choice == null) return;

    await cubit.setLocale(choice == 'system' ? null : Locale(choice));
  }
}
