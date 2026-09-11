import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/utils/prayer_slot_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/option_picker_sheet.dart';
import '../../../../core/widgets/setting_tile.dart';
import '../../../../core/widgets/settings_scaffold.dart';
import '../../domain/entities/notification_sound.dart';
import '../../domain/entities/prayer_notification_pref.dart';
import '../bloc/notification_settings_cubit.dart';

/// Notification preferences, and the OS permissions they depend on.
@RoutePage()
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  /// Offered pre-reminder offsets. Zero is "off".
  static const List<int> preReminderChoices = [0, 5, 10, 15, 30];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationSettingsCubit>();
        final settings = state.settings;

        return SettingsScaffold(
          title: l10n.settingsNotification,
          children: [
            // Permission problems come first: everything below is inert
            // until they are resolved, and silent failure is the worst
            // outcome for a reminder app.
            if (!state.hasPermission)
              _WarningCard(
                title: l10n.notificationPermissionTitle,
                body: l10n.notificationPermissionBody,
                actionLabel: l10n.permissionGrant,
                onPressed: cubit.requestPermission,
              ),
            if (state.hasPermission && !state.canScheduleExactAlarms)
              _WarningCard(
                title: l10n.exactAlarmPermissionTitle,
                body: l10n.exactAlarmPermissionBody,
                actionLabel: l10n.permissionFix,
                onPressed: cubit.openExactAlarmSettings,
              ),

            SettingTile.toggle(
              title: l10n.notificationActivate,
              subtitle: l10n.notificationActivateSubtitle,
              value: settings.masterEnabled,
              onChanged: cubit.setMasterEnabled,
            ),

            SettingSectionHeader(title: l10n.notificationPerPrayer),

            for (final slot in NotificationSettings.notifiable)
              if (slot != PrayerSlot.jumuah)
                _PrayerRow(
                  slot: slot,
                  pref: settings.prefFor(slot),
                  enabled: settings.masterEnabled,
                  l10n: l10n,
                ),

            SettingSectionHeader(title: l10n.settingsFajrAlarm),

            SettingTile.toggle(
              title: l10n.settingsFajrAlarm,
              subtitle: l10n.settingsFajrAlarmSubtitle,
              value: settings.fajrAlarm.enabled,
              onChanged: settings.masterEnabled
                  ? (value) => cubit.setFajrAlarm(
                      settings.fajrAlarm.copyWith(enabled: value),
                    )
                  : null,
            ),
            if (settings.fajrAlarm.enabled)
              SettingTile.navigation(
                title: l10n.fajrAlarmMinutesTitle,
                value: l10n.minutesShort(settings.fajrAlarm.minutesBeforeFajr),
                onTap: () async {
                  const choices = [15, 30, 45, 60, 90];
                  final choice = await OptionPickerSheet.show<int>(
                    context: context,
                    title: l10n.fajrAlarmMinutesTitle,
                    options: choices,
                    selected:
                        choices.contains(settings.fajrAlarm.minutesBeforeFajr)
                        ? settings.fajrAlarm.minutesBeforeFajr
                        : 30,
                    labelOf: l10n.minutesShort,
                  );
                  if (choice != null) {
                    await cubit.setFajrAlarm(
                      settings.fajrAlarm.copyWith(minutesBeforeFajr: choice),
                    );
                  }
                },
              ),

            const SizedBox(height: AppSpacing.sm),
            SettingTile.navigation(
              title: l10n.notificationTest,
              subtitle: l10n.notificationTestSubtitle,
              enabled: state.hasPermission,
              onTap: cubit.sendTestNotification,
            ),
          ],
        );
      },
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.slot,
    required this.pref,
    required this.enabled,
    required this.l10n,
  });

  final PrayerSlot slot;
  final PrayerNotificationPref pref;
  final bool enabled;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationSettingsCubit>();

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: GlassCard(
          radius: AppSpacing.radiusMd,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(slot.label(l10n), style: AppTextStyle.rowLabel),
                  ),
                  Switch.adaptive(
                    value: pref.enabled,
                    onChanged: enabled
                        ? (value) => cubit.togglePrayer(slot, value)
                        : null,
                  ),
                ],
              ),
              if (pref.enabled && enabled) ...[
                const Divider(height: AppSpacing.xl),
                _InlinePicker(
                  label: l10n.notificationSound,
                  value: _soundLabel(pref.sound, l10n),
                  onTap: () async {
                    final choice =
                        await OptionPickerSheet.show<NotificationSound>(
                          context: context,
                          title: l10n.notificationSound,
                          options: const [
                            NotificationSound.adhanShort,
                            NotificationSound.defaultTone,
                            NotificationSound.silent,
                          ],
                          selected: pref.sound,
                          labelOf: (s) => _soundLabel(s, l10n),
                        );
                    if (choice != null) {
                      await cubit.setPref(pref.copyWith(sound: choice));
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _InlinePicker(
                  label: l10n.preReminderTitle,
                  value: pref.hasPreReminder
                      ? l10n.minutesShort(pref.preReminderMinutes)
                      : l10n.preReminderOff,
                  onTap: () async {
                    final choice = await OptionPickerSheet.show<int>(
                      context: context,
                      title: l10n.preReminderTitle,
                      options: NotificationSettingsScreen.preReminderChoices,
                      selected: pref.preReminderMinutes,
                      labelOf: (m) =>
                          m == 0 ? l10n.preReminderOff : l10n.minutesShort(m),
                    );
                    if (choice != null) {
                      await cubit.setPref(
                        pref.copyWith(preReminderMinutes: choice),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _soundLabel(NotificationSound sound, AppLocalizations l10n) =>
      switch (sound) {
        NotificationSound.silent => l10n.soundSilent,
        NotificationSound.defaultTone => l10n.soundDefault,
        NotificationSound.adhanShort => l10n.soundAdhanShort,
      };
}

class _InlinePicker extends StatelessWidget {
  const _InlinePicker({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyle.bodySmall)),
          Text(value, style: AppTextStyle.rowLabel),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GlassCard(
        radius: AppSpacing.radiusMd,
        fill: AppColors.warning.withValues(alpha: 0.14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyle.rowLabel),
            const SizedBox(height: AppSpacing.xxs),
            Text(body, style: AppTextStyle.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onPressed, child: Text(actionLabel)),
            ),
          ],
        ),
      ),
    );
  }
}
