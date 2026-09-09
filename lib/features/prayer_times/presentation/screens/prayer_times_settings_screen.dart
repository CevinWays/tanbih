import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/calculation_presets.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/routes/app_router.gr.dart';
import '../../../../core/utils/calculation_labels.dart';
import '../../../../core/widgets/option_picker_sheet.dart';
import '../../../../core/widgets/setting_tile.dart';
import '../../../../core/widgets/settings_scaffold.dart';
import '../../domain/entities/calculation_settings.dart';
import '../bloc/calculation_settings_cubit.dart';

/// Everything that changes how prayer times are computed.
@RoutePage()
class PrayerTimesSettingsScreen extends StatelessWidget {
  const PrayerTimesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<CalculationSettingsCubit, CalculationSettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final cubit = context.read<CalculationSettingsCubit>();

        return SettingsScaffold(
          title: l10n.settingsPrayerTimes,
          children: [
            SettingSectionHeader(title: l10n.settingsCalculations),

            SettingTile.navigation(
              title: l10n.settingsMethods,
              value: settings.method.label(l10n),
              onTap: () => _pickMethod(context, cubit, settings, l10n),
            ),
            SettingTile.navigation(
              title: l10n.settingsJuristicMethod,
              value: settings.madhab.label(l10n),
              onTap: () => _pickMadhab(context, cubit, settings, l10n),
            ),
            SettingTile.navigation(
              title: l10n.settingsHigherLatitude,
              value: settings.highLatitudeRule.label(l10n),
              onTap: () => _pickHighLatitude(context, cubit, settings, l10n),
            ),

            // Only Umm Al-Qura defines this correction. Showing the switch
            // under other methods would offer a control that does nothing.
            if (settings.method.supportsRamadanIshaAdjustment)
              SettingTile.toggle(
                title: l10n.settingsRamadanIsha,
                subtitle: l10n.settingsRamadanIshaSubtitle,
                value: settings.adjustIshaInRamadan,
                onChanged: (value) =>
                    cubit.update(settings.copyWith(adjustIshaInRamadan: value)),
              ),

            SettingSectionHeader(title: l10n.settingsTimes),

            SettingTile.toggle(
              title: l10n.settingsDst,
              subtitle: l10n.settingsDstSubtitle,
              value: settings.adjustDaylightSaving,
              onChanged: (value) =>
                  cubit.update(settings.copyWith(adjustDaylightSaving: value)),
            ),
            SettingTile.navigation(
              title: l10n.settingsJumuah,
              value: settings.hasJumuahTime
                  ? _formatTime(settings.jumuahHour!, settings.jumuahMinute!)
                  : l10n.settingsJumuahSubtitle,
              onTap: () => _pickJumuahTime(context, cubit, settings),
            ),
            SettingTile.navigation(
              title: l10n.settingsImsakOffset,
              value: l10n.minutesShort(settings.imsakOffsetMinutes),
              onTap: () => _pickImsakOffset(context, cubit, settings, l10n),
            ),
            SettingTile.navigation(
              title: l10n.settingsManualAdjustments,
              subtitle: l10n.settingsManualAdjustmentsSubtitle,
              onTap: () => context.router.push(const ManualAdjustmentsRoute()),
            ),
          ],
        );
      },
    );
  }

  static String _formatTime(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Future<void> _pickMethod(
    BuildContext context,
    CalculationSettingsCubit cubit,
    CalculationSettings settings,
    AppLocalizations l10n,
  ) async {
    final choice = await OptionPickerSheet.show<CalculationMethodId>(
      context: context,
      title: l10n.settingsMethods,
      options: CalculationMethodId.values,
      selected: settings.method,
      labelOf: (m) => m.label(l10n),
      subtitleOf: (m) => m.subtitle(l10n),
    );
    if (choice == null) return;

    // Switching away from Umm Al-Qura hides the Ramadan switch, so clear the
    // flag with it — a hidden `true` would keep shifting Isha invisibly if
    // the user ever switched back.
    await cubit.update(
      settings.copyWith(
        method: choice,
        adjustIshaInRamadan: choice.supportsRamadanIshaAdjustment
            ? settings.adjustIshaInRamadan
            : false,
      ),
    );
  }

  Future<void> _pickMadhab(
    BuildContext context,
    CalculationSettingsCubit cubit,
    CalculationSettings settings,
    AppLocalizations l10n,
  ) async {
    final choice = await OptionPickerSheet.show<MadhabId>(
      context: context,
      title: l10n.settingsJuristicMethod,
      options: MadhabId.values,
      selected: settings.madhab,
      labelOf: (m) => m.label(l10n),
    );
    if (choice != null) await cubit.update(settings.copyWith(madhab: choice));
  }

  Future<void> _pickHighLatitude(
    BuildContext context,
    CalculationSettingsCubit cubit,
    CalculationSettings settings,
    AppLocalizations l10n,
  ) async {
    final choice = await OptionPickerSheet.show<HighLatitudeRuleId>(
      context: context,
      title: l10n.settingsHigherLatitude,
      options: HighLatitudeRuleId.values,
      selected: settings.highLatitudeRule,
      labelOf: (r) => r.label(l10n),
    );
    if (choice != null) {
      await cubit.update(settings.copyWith(highLatitudeRule: choice));
    }
  }

  Future<void> _pickJumuahTime(
    BuildContext context,
    CalculationSettingsCubit cubit,
    CalculationSettings settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.hasJumuahTime
          ? TimeOfDay(
              hour: settings.jumuahHour!,
              minute: settings.jumuahMinute!,
            )
          : const TimeOfDay(hour: 12, minute: 15),
    );
    if (picked == null) return;

    await cubit.update(
      settings.copyWith(jumuahHour: picked.hour, jumuahMinute: picked.minute),
    );
  }

  Future<void> _pickImsakOffset(
    BuildContext context,
    CalculationSettingsCubit cubit,
    CalculationSettings settings,
    AppLocalizations l10n,
  ) async {
    const choices = [5, 8, 10, 12, 15, 20];
    final choice = await OptionPickerSheet.show<int>(
      context: context,
      title: l10n.settingsImsakOffset,
      options: choices,
      selected: choices.contains(settings.imsakOffsetMinutes)
          ? settings.imsakOffsetMinutes
          : CalculationSettings.defaultImsakOffsetMinutes,
      labelOf: l10n.minutesShort,
    );
    if (choice != null) {
      await cubit.update(settings.copyWith(imsakOffsetMinutes: choice));
    }
  }
}
