import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/settings_scaffold.dart';
import '../../../prayer_times/presentation/bloc/calculation_settings_cubit.dart';

/// Shifts the Hijri date by whole days.
///
/// The civil Hijri calendar and local moon sighting routinely disagree by a
/// day or two, so users expect to be able to line the app up with whatever
/// their community follows.
@RoutePage()
class HijriSettingsScreen extends StatelessWidget {
  const HijriSettingsScreen({super.key});

  static const int limitDays = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<CalculationSettingsCubit, CalculationSettingsState>(
      builder: (context, state) {
        final offset = state.settings.hijriOffsetDays;
        final cubit = context.read<CalculationSettingsCubit>();

        return SettingsScaffold(
          title: l10n.settingsHijri,
          children: [
            GlassCard(
              radius: AppSpacing.radiusMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.hijriOffsetTitle, style: AppTextStyle.rowLabel),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(l10n.hijriOffsetSubtitle, style: AppTextStyle.bodySmall),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: offset > -limitDays
                            ? () => cubit.update(
                                state.settings.copyWith(
                                  hijriOffsetDays: offset - 1,
                                ),
                              )
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.brandSolid,
                      ),
                      SizedBox(
                        width: 96,
                        child: Text(
                          offset > 0
                              ? '+${l10n.dayOffsetValue(offset)}'
                              : l10n.dayOffsetValue(offset),
                          textAlign: TextAlign.center,
                          style: AppTextStyle.prayerTime,
                        ),
                      ),
                      IconButton(
                        onPressed: offset < limitDays
                            ? () => cubit.update(
                                state.settings.copyWith(
                                  hijriOffsetDays: offset + 1,
                                ),
                              )
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.brandSolid,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
