import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/routes/app_router.gr.dart';
import '../../../../core/styles/styles.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../location/presentation/bloc/location_event.dart';
import '../../../location/presentation/bloc/location_state.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../bloc/next_prayer_countdown_cubit.dart';
import '../bloc/prayer_times_bloc.dart';
import '../bloc/prayer_times_event.dart';
import '../bloc/prayer_times_state.dart';
import '../widgets/home_header.dart';
import '../widgets/prayer_countdown_carousel.dart';
import '../widgets/prayer_row_tile.dart';
import '../widgets/suhoor_iftaar_card.dart';

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
      child: const _HomeView(),
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
          BlocListener<PrayerTimesBloc, PrayerTimesState>(
            listenWhen: (previous, current) =>
                current.times != null && previous.times != current.times,
            listener: (context, state) =>
                context.read<NextPrayerCountdownCubit>().track(state.times!),
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
    final countdown = context.watch<NextPrayerCountdownCubit>().state;

    final times = prayerState.times;

    return ColoredBox(
      color: AppColors.surfaceLight,
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
              onMenuTap: () => context.router.push(const MenuRoute()),
              onDateTap: () => context.router.push(const AllPrayerRoute()),
              child: PrayerCountdownCarousel(
                entries: times?.prayerEntries ?? const [],
                nextSlot: countdown.slot,
                remaining: countdown.remaining,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            switch (prayerState.status) {
              PrayerTimesStatus.success => _Schedule(
                times: times!,
                currentSlot: _currentSlot(times, countdown.slot),
              ),
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

/// The prayer in effect right now — the one just before the countdown's
/// target.
///
/// Derived from the countdown rather than from `DateTime.now()` so it
/// advances on the same tick the countdown does, and so nothing here reads
/// the clock directly.
PrayerSlot? _currentSlot(DailyPrayerTimes times, PrayerSlot? nextSlot) {
  final prayers = times.prayerEntries;
  if (nextSlot == null) return prayers.isEmpty ? null : prayers.last.slot;

  final index = prayers.indexWhere((e) => e.slot == nextSlot);
  return index <= 0 ? null : prayers[index - 1].slot;
}

class _Schedule extends StatelessWidget {
  const _Schedule({required this.times, this.currentSlot});

  final DailyPrayerTimes times;
  final PrayerSlot? currentSlot;

  @override
  Widget build(BuildContext context) {
    final imsak = times.entryFor(PrayerSlot.imsak);
    final maghrib = times.entryFor(PrayerSlot.maghrib);

    return SizedBox(
      width: AppSpacing.contentWidth,
      child: Column(
        children: [
          if (imsak != null && maghrib != null)
            SuhoorIftaarCard(suhoor: imsak.time, iftaar: maghrib.time),
          const SizedBox(height: AppSpacing.xl),
          // Only the prayers: imsak already has its own card above, and
          // sunrise is shown on the All Prayer screen rather than here.
          for (final entry in times.prayerEntries) ...[
            PrayerRowTile(
              entry: entry,
              highlighted: entry.slot == currentSlot,
              // Per-prayer notification switching arrives with the
              // notification feature; the control is inert until then.
              notificationEnabled: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
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
