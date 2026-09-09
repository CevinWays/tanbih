import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/routes/app_router.gr.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/setting_tile.dart';
import '../../../../core/widgets/settings_scaffold.dart';
import '../../domain/entities/prayer_location.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

/// Where prayer times are computed for, and how that place is decided.
@RoutePage()
class LocationSettingsScreen extends StatelessWidget {
  const LocationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final location = state.location;

        return SettingsScaffold(
          title: l10n.settingsLocation,
          children: [
            _CurrentLocationCard(location: location, state: state),
            const SizedBox(height: AppSpacing.lg),

            SettingTile.navigation(
              title: l10n.locationCurrent,
              value: location?.isManual ?? false
                  ? l10n.locationChooseManually
                  : l10n.locationTapToChange,
              onTap: () => context.read<LocationBloc>().add(
                const LocationRefreshRequested(),
              ),
            ),
            SettingTile.navigation(
              title: l10n.locationChooseManually,
              subtitle: l10n.commonSearch,
              onTap: () => context.router.push(const CityPickerRoute()),
            ),

            if (state.isPermanentlyDenied)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  l10n.locationPermissionDeniedForever,
                  style: AppTextStyle.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({required this.location, required this.state});

  final PrayerLocation? location;
  final LocationState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return GlassCard(
      radius: AppSpacing.radiusMd,
      child: Row(
        children: [
          const Icon(Icons.place_outlined, color: AppColors.brandSolid),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location?.displayName ?? l10n.locationUnknown,
                  style: AppTextStyle.rowLabel,
                ),
                Text(
                  // The zone is worth showing here: a manually picked city
                  // in another zone is exactly the case where a user would
                  // otherwise be baffled by the times.
                  location?.timeZoneId ?? '',
                  style: AppTextStyle.bodySmall,
                ),
              ],
            ),
          ),
          if (state.isRefreshing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
