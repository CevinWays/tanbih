import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/routes/app_router.gr.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../location/presentation/bloc/location_event.dart';
import '../../../location/presentation/bloc/location_state.dart';
import '../../../onboarding/presentation/widgets/startup_permission_gate.dart';
import '../../../settings/data/datasources/app_preferences_local_data_source.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../bloc/calculation_settings_cubit.dart';
import '../bloc/next_prayer_countdown_cubit.dart';
import '../bloc/prayer_times_bloc.dart';
import '../bloc/prayer_times_event.dart';
import '../bloc/prayer_times_state.dart';
import '../widgets/home_header.dart';
import '../widgets/prayer_countdown_hero.dart';
import '../widgets/prayer_schedule_card.dart';

/// The main screen: today's schedule for the current location.
@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PrayerTimesBloc>()),
        BlocProvider(create: (_) => sl<NextPrayerCountdownCubit>()),
      ],
      child: StartupPermissionGate(
        preferences: sl<AppPreferencesLocalDataSource>(),
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The location feed drives everything else: once a position resolves,
      // the schedule is recomputed for it.
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationBloc, LocationState>(
            listenWhen: (previous, current) =>
                current.location != null &&
                previous.location != current.location,
            listener: (context, state) {
              final location = state.location!;
              context.read<PrayerTimesBloc>().add(
                PrayerTimesLoadRequested(
                  latitude: location.latitude,
                  longitude: location.longitude,
                  timeZoneId: location.timeZoneId,
                ),
              );
            },
          ),
          // Settings live in their own app-wide cubit, so the schedule
          // recomputes as soon as one changes — the settings screens do not
          // need to know who depends on them.
          BlocListener<CalculationSettingsCubit, CalculationSettingsState>(
            listenWhen: (previous, current) =>
                previous.settings != current.settings,
            listener: (context, state) => context.read<PrayerTimesBloc>().add(
              PrayerTimesSettingsChanged(state.settings),
            ),
          ),
          BlocListener<PrayerTimesBloc, PrayerTimesState>(
            listenWhen: (previous, current) =>
                current.times != null && previous.times != current.times,
            listener: (context, state) =>
                context.read<NextPrayerCountdownCubit>().track(
                  today: state.times!,
                  yesterday: state.previousTimes,
                  tomorrow: state.nextTimes,
                ),
          ),
          // Past midnight with the app still open, the schedule on screen is
          // yesterday's. The countdown notices first — it is the only thing
          // here reading the clock — and asks for a fresh window.
          BlocListener<NextPrayerCountdownCubit, CountdownState>(
            listenWhen: (previous, current) =>
                !previous.needsReload && current.needsReload,
            listener: (context, _) => context.read<PrayerTimesBloc>().add(
              const PrayerTimesTodayRequested(),
            ),
          ),
        ],
        child: const _HomeBody(),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locationState = context.watch<LocationBloc>().state;
    final prayerState = context.watch<PrayerTimesBloc>().state;

    // Deliberately no watch on the countdown here. Reading it at this level
    // rebuilt the header, the schedule and every row once a second, and
    // re-recorded the hero's blur along with them. The hero and the row
    // highlight subscribe to it themselves, further down.
    final times = prayerState.times;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeader(
              locationLabel:
                  locationState.location?.displayName ?? l10n.locationUnknown,
              isRefreshingLocation: locationState.isRefreshing,
              date: prayerState.selectedDate,
              hijriDate: times?.hijriDate,
              onLocationTap: () => context.read<LocationBloc>().add(
                const LocationRefreshRequested(),
              ),
              onSettingsTap: () => context.router.push(const SettingsRoute()),
              onMenuTap: () => context.router.push(const MenuRoute()),
              onDateTap: () => context.router.push(const AllPrayerRoute()),
              child: const PrayerCountdownHero(),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!locationState.hasLocation &&
                locationState.status == LocationStatus.failure)
              _LocationFailedCard(state: locationState)
            else
              switch (prayerState.status) {
                PrayerTimesStatus.success => _Schedule(times: times!),
                PrayerTimesStatus.failure => _ScheduleMessage(
                  message: prayerState.failure?.message.isNotEmpty ?? false
                      ? prayerState.failure!.message
                      : l10n.errorCalculation,
                ),
                PrayerTimesStatus.loading ||
                PrayerTimesStatus.initial => const Padding(
                  padding: EdgeInsets.all(AppSpacing.xxxl),
                  child: CircularProgressIndicator(),
                ),
              },
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}

/// Shown when the location could not be resolved and there is no cached one.
///
/// Without this the screen spins forever: nothing further is coming, and the
/// user is given no way to act.
class _LocationFailedCard extends StatelessWidget {
  const _LocationFailedCard({required this.state});

  final LocationState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = state.isPermanentlyDenied
        ? l10n.locationPermissionDeniedForever
        : (state.failure?.message.isNotEmpty ?? false
              ? state.failure!.message
              : l10n.locationFailedTitle);

    return _BodySection(
      child: GlassCard(
        radius: AppSpacing.radiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.locationFailedTitle, style: AppTextStyle.rowLabel),
            const SizedBox(height: AppSpacing.xxs),
            Text(message, style: AppTextStyle.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.read<LocationBloc>().add(
                    const LocationRefreshRequested(),
                  ),
                  child: Text(l10n.locationRetry),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: () => context.router.push(const CityPickerRoute()),
                  child: Text(l10n.locationChooseManually),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({required this.times});

  final DailyPrayerTimes times;

  @override
  Widget build(BuildContext context) {
    final imsak = times.entryFor(PrayerSlot.imsak);
    final maghrib = times.entryFor(PrayerSlot.maghrib);

    return _BodySection(
      // A narrow subscription: the highlight moves five times a day, so the
      // list must not be rebuilt on the countdown's per-second ticks.
      child: BlocSelector<NextPrayerCountdownCubit, CountdownState, PrayerSlot?>(
        selector: (state) => state.currentSlot,
        builder: (context, currentSlot) => PrayerScheduleCard(
          // Only the prayers: imsak rides on the fasting row, and sunrise is
          // shown on the All Prayer screen rather than here.
          entries: times.prayerEntries,
          currentSlot: currentSlot,
          suhoor: imsak?.time,
          iftaar: maghrib?.time,
        ),
      ),
    );
  }
}

/// The gutter every block of the Home body sits in.
///
/// The design centred a fixed 306dp column, which left a wide dead margin on
/// a modern phone and overflowed on a narrow one. Stretching to the screen
/// with the standard padding fixes both; the cap only matters on tablets.
class _BodySection extends StatelessWidget {
  const _BodySection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ScheduleMessage extends StatelessWidget {
  const _ScheduleMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
