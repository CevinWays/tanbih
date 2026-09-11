import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

/// Search for a city, or browse the bundled Indonesian list.
///
/// The list is available with no connection at all, which is the whole point
/// of bundling it: a denied location permission plus no network still has to
/// produce a usable schedule.
@RoutePage()
class CityPickerScreen extends StatefulWidget {
  const CityPickerScreen({super.key});

  @override
  State<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<CityPickerScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Populate with the bundled list so the screen is never empty on open.
    context.read<LocationBloc>().add(const LocationCitySearchCleared());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.locationChooseManually)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.commonSearch,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => context.read<LocationBloc>().add(
                LocationCitySearchChanged(value),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<LocationBloc, LocationState>(
              builder: (context, state) {
                if (state.searchStatus == CitySearchStatus.loading &&
                    state.searchResults.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.locationUnknown,
                      style: AppTextStyle.bodySmall,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.huge,
                  ),
                  itemCount: state.searchResults.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final city = state.searchResults[index];
                    final selected =
                        state.location?.city == city.name &&
                        (state.location?.isManual ?? false);

                    return GlassCard(
                      radius: AppSpacing.radiusMd,
                      onTap: () {
                        context.read<LocationBloc>().add(
                          LocationCitySelected(city),
                        );
                        context.router.maybePop();
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city.displayName,
                                  style: AppTextStyle.rowLabel,
                                ),
                                Text(
                                  city.timeZoneId.isEmpty
                                      ? (city.country ?? '')
                                      : city.timeZoneId,
                                  style: AppTextStyle.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.brandSolid,
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
