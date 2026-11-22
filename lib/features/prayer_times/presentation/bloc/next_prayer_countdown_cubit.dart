import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/utils/app_durations.dart';
import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/entities/prayer_time_entry.dart';

/// What the hero is doing right now.
enum CountdownPhase {
  /// No schedule yet.
  idle,

  /// Counting down to [CountdownState.slot].
  counting,

  /// A prayer time has just arrived and is being announced.
  arrived,
}

/// What the circular countdown on Home needs, and nothing else.
class CountdownState extends Equatable {
  const CountdownState({
    this.phase = CountdownPhase.idle,
    this.slot,
    this.slotTime,
    this.remaining,
    this.currentSlot,
    this.progress = 0,
    this.needsReload = false,
  });

  final CountdownPhase phase;

  /// The prayer the hero is showing — the next one, or the one that just
  /// arrived.
  final PrayerSlot? slot;

  /// That prayer's clock time.
  final DateTime? slotTime;

  /// Null unless [phase] is [CountdownPhase.counting].
  final Duration? remaining;

  /// The prayer in effect, for the schedule list's highlight.
  final PrayerSlot? currentSlot;

  /// How far along we are between the previous prayer and the next, 0..1.
  final double progress;

  /// The calendar day moved on and the schedule on screen is yesterday's.
  /// Home reloads when it sees this; the cubit keeps ticking either way.
  final bool needsReload;

  bool get isActive => phase != CountdownPhase.idle;

  CountdownState copyWith({bool? needsReload}) => CountdownState(
    phase: phase,
    slot: slot,
    slotTime: slotTime,
    remaining: remaining,
    currentSlot: currentSlot,
    progress: progress,
    needsReload: needsReload ?? this.needsReload,
  );

  @override
  List<Object?> get props => [
    phase,
    slot,
    slotTime,
    remaining,
    currentSlot,
    progress,
    needsReload,
  ];
}

/// Ticks once per second, in isolation.
///
/// Kept apart from `PrayerTimesBloc` on purpose: re-emitting the full prayer
/// list every second would rebuild the whole screen sixty times a minute.
/// This cubit emits only what the hero and the row highlight need.
@injectable
class NextPrayerCountdownCubit extends Cubit<CountdownState> {
  NextPrayerCountdownCubit(this._clock) : super(const CountdownState());

  final Clock _clock;

  Timer? _timer;
  DailyPrayerTimes? _today;
  DailyPrayerTimes? _yesterday;
  DailyPrayerTimes? _tomorrow;

  /// Point the countdown at a schedule and start ticking.
  ///
  /// [yesterday] and [tomorrow] are what let the countdown survive the edges
  /// of the day: without [tomorrow] there is nothing to count to after Isha,
  /// and without [yesterday] the ring has no starting point for Fajr.
  ///
  /// Safe to call repeatedly — the previous timer is always cancelled first,
  /// so a rapid sequence of loads cannot leave several timers running.
  void track({
    required DailyPrayerTimes today,
    DailyPrayerTimes? yesterday,
    DailyPrayerTimes? tomorrow,
  }) {
    _today = today;
    _yesterday = yesterday;
    _tomorrow = tomorrow;
    _timer?.cancel();
    _tick();
    _timer = Timer.periodic(AppDurations.tick, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Recompute now. Tests drive this directly rather than waiting a second.
  @visibleForTesting
  void tickNow() => _tick();

  void _tick() {
    final today = _today;
    if (today == null) return;

    final now = _clock.now();

    // The day rolled over while the app sat open. Keep counting with what we
    // have — Home reloads and calls track() again with a fresh window.
    if (_clock.today().isAfter(today.date)) {
      if (!state.needsReload) emit(state.copyWith(needsReload: true));
      return;
    }

    final current =
        today.currentPrayerAt(now) ?? _yesterday?.prayerEntries.lastOrNull;

    // A prayer time that has only just passed is worth saying out loud.
    // Derived from the schedule rather than remembered, so it survives a
    // reload, a settings change, or the app being reopened mid-adhan.
    if (current != null &&
        now.difference(current.time) < AppDurations.arrivalHold) {
      emit(
        CountdownState(
          phase: CountdownPhase.arrived,
          slot: current.slot,
          slotTime: current.time,
          currentSlot: current.slot,
          progress: 1,
        ),
      );
      return;
    }

    final next =
        today.nextPrayerAt(now) ?? _tomorrow?.prayerEntries.firstOrNull;
    if (next == null) {
      // Past Isha with no schedule for tomorrow: nothing honest to show.
      emit(CountdownState(currentSlot: current?.slot));
      return;
    }

    emit(
      CountdownState(
        phase: CountdownPhase.counting,
        slot: next.slot,
        slotTime: next.time,
        remaining: next.time.difference(now),
        currentSlot: current?.slot,
        progress: _progress(now: now, anchor: current, target: next),
      ),
    );
  }

  /// How far we have come from the previous prayer towards the next.
  ///
  /// Zero when there is no anchor to measure from — an empty ring is honest,
  /// a guessed one is not.
  double _progress({
    required DateTime now,
    required PrayerTimeEntry? anchor,
    required PrayerTimeEntry target,
  }) {
    if (anchor == null) return 0;

    final window = target.time.difference(anchor.time).inMilliseconds;
    if (window <= 0) return 0;

    final elapsed = now.difference(anchor.time).inMilliseconds;
    return (elapsed / window).clamp(0.0, 1.0);
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
