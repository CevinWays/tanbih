import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/styles/styles.dart';
import '../../../../core/utils/prayer_slot_x.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../bloc/monthly_schedule_cubit.dart';

/// The whole month at a glance.
@RoutePage()
class AllPrayerScreen extends StatelessWidget {
  const AllPrayerScreen({super.key});

  /// Columns shown in the table. Imsak and sunrise are left out: this view
  /// is for planning around the five prayers, and seven columns do not fit
  /// a phone width legibly.
  static const List<PrayerSlot> columns = [
    PrayerSlot.fajr,
    PrayerSlot.dhuhr,
    PrayerSlot.asr,
    PrayerSlot.maghrib,
    PrayerSlot.isha,
  ];

  @override
  Widget build(BuildContext context) {
    final location = context.read<LocationBloc>().state.location;

    return BlocProvider(
      create: (_) {
        final cubit = sl<MonthlyScheduleCubit>();
        if (location != null) {
          cubit.load(
            latitude: location.latitude,
            longitude: location.longitude,
            timeZoneId: location.timeZoneId,
          );
        }
        return cubit;
      },
      child: const _AllPrayerView(),
    );
  }
}

class _AllPrayerView extends StatelessWidget {
  const _AllPrayerView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locationState = context.watch<LocationBloc>().state;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          _Header(
            title: l10n.allPrayersTitle,
            locationLabel:
                locationState.location?.displayName ?? l10n.locationUnknown,
          ),
          Expanded(
            child: BlocBuilder<MonthlyScheduleCubit, MonthlyScheduleState>(
              builder: (context, state) => switch (state.status) {
                MonthlyScheduleStatus.success => _MonthTable(
                  days: state.days,
                  today: state.today,
                ),
                MonthlyScheduleStatus.failure => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Text(
                      state.failure?.message.isNotEmpty ?? false
                          ? state.failure!.message
                          : l10n.errorCalculation,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                MonthlyScheduleStatus.loading ||
                MonthlyScheduleStatus.initial => const Center(
                  child: CircularProgressIndicator(),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.locationLabel});

  final String title;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryVertical,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.headerRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const BackButton(color: Colors.white),
                  Expanded(
                    child: Text(title, style: AppTextStyle.onHeaderLabel),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                fill: AppColors.glassFill,
                radius: AppSpacing.radiusMd,
                child: Center(
                  child: Text(
                    locationLabel,
                    style: AppTextStyle.onHeaderLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthTable extends StatelessWidget {
  const _MonthTable({required this.days, required this.today});

  final List<DailyPrayerTimes> days;

  /// Midnight today, from the cubit's injected clock.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dayFormat = DateFormat('dd MMM', locale);
    final timeFormat = DateFormat.jm(locale);

    // A month of five time columns does not fit a phone width, so the table
    // scrolls sideways rather than truncating the times.
    return Column(
      children: [
        _HeaderRow(
          firstColumn: days.isEmpty
              ? ''
              : DateFormat('yyyy', locale).format(days.first.date),
          l10n: l10n,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              return _DayRow(
                label: dayFormat.format(day.date),
                times: [
                  for (final slot in AllPrayerScreen.columns)
                    day.entryFor(slot) == null
                        ? '—'
                        : timeFormat.format(day.entryFor(slot)!.time),
                ],
                isToday:
                    today != null &&
                    day.date.year == today!.year &&
                    day.date.month == today!.month &&
                    day.date.day == today!.day,
                striped: index.isOdd,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.firstColumn, required this.l10n});

  final String firstColumn;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(firstColumn, style: AppTextStyle.label),
          ),
          for (final slot in AllPrayerScreen.columns)
            Expanded(
              child: Text(
                slot.label(l10n),
                style: AppTextStyle.label,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.label,
    required this.times,
    required this.isToday,
    required this.striped,
  });

  final String label;
  final List<String> times;

  /// Today's row is called out in the brand colour — it is the row a user
  /// opening this screen is nearly always looking for.
  final bool isToday;

  /// Faint alternating band, so the eye can track across five columns.
  final bool striped;

  @override
  Widget build(BuildContext context) {
    final textStyle = isToday
        ? AppTextStyle.bodySmall.copyWith(
            color: AppColors.textOnBrand,
            fontWeight: FontWeight.w600,
          )
        : AppTextStyle.bodySmall;

    return ColoredBox(
      color: isToday
          ? AppColors.brandSolid
          : (striped ? Colors.white54 : Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            SizedBox(width: 56, child: Text(label, style: textStyle)),
            for (final time in times)
              Expanded(
                child: Text(
                  time,
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
