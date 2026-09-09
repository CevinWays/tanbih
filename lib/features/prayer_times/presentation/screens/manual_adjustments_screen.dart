import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/utils/prayer_slot_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/settings_scaffold.dart';
import '../bloc/calculation_settings_cubit.dart';

/// Per-prayer minute offsets, on top of whatever the chosen method already
/// applies.
///
/// Needed because published local timetables sometimes differ from any
/// standard method by a minute or two, and a user who trusts their mosque's
/// board should be able to match it exactly.
@RoutePage()
class ManualAdjustmentsScreen extends StatelessWidget {
  const ManualAdjustmentsScreen({super.key});

  /// Every row that can be shifted. Jumu'ah is set as an absolute time
  /// elsewhere, so it is not offset here.
  static const List<PrayerSlot> adjustable = [
    PrayerSlot.imsak,
    PrayerSlot.fajr,
    PrayerSlot.sunrise,
    PrayerSlot.dhuhr,
    PrayerSlot.asr,
    PrayerSlot.maghrib,
    PrayerSlot.isha,
  ];

  /// Beyond this the schedule stops resembling a calculated one, and the
  /// user almost certainly wants a different method instead.
  static const int limitMinutes = 60;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<CalculationSettingsCubit, CalculationSettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final cubit = context.read<CalculationSettingsCubit>();

        return SettingsScaffold(
          title: l10n.settingsManualAdjustments,
          actions: [
            if (settings.manualAdjustments.values.any((v) => v != 0))
              TextButton(
                onPressed: () => cubit.update(
                  settings.copyWith(manualAdjustments: const {}),
                ),
                child: Text(
                  l10n.settingsResetAdjustments,
                  style: AppTextStyle.bodySmall.copyWith(color: Colors.white),
                ),
              ),
          ],
          children: [
            for (final slot in adjustable)
              _AdjustmentRow(
                label: slot.label(l10n),
                minutes: settings.adjustmentFor(slot),
                onChanged: (value) {
                  final next = Map<PrayerSlot, int>.from(
                    settings.manualAdjustments,
                  );
                  if (value == 0) {
                    next.remove(slot);
                  } else {
                    next[slot] = value;
                  }
                  cubit.update(settings.copyWith(manualAdjustments: next));
                },
              ),
          ],
        );
      },
    );
  }
}

class _AdjustmentRow extends StatelessWidget {
  const _AdjustmentRow({
    required this.label,
    required this.minutes,
    required this.onChanged,
  });

  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const limit = ManualAdjustmentsScreen.limitMinutes;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        radius: AppSpacing.radiusMd,
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyle.rowLabel)),
            IconButton(
              onPressed: minutes > -limit ? () => onChanged(minutes - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.brandSolid,
            ),
            SizedBox(
              width: 56,
              child: Text(
                minutes > 0 ? '+$minutes' : '$minutes',
                textAlign: TextAlign.center,
                style: AppTextStyle.prayerTime,
              ),
            ),
            IconButton(
              onPressed: minutes < limit ? () => onChanged(minutes + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.brandSolid,
            ),
          ],
        ),
      ),
    );
  }
}
