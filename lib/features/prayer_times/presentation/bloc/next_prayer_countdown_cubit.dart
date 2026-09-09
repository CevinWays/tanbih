import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/prayer_slot.dart';
import '../../../../core/services/clock.dart';
import '../../domain/entities/daily_prayer_times.dart';

/// What the circular countdown on Home needs, and nothing else.
class CountdownState extends Equatable {
  const CountdownState({this.slot, this.remaining, this.elapsed = false});

  /// Prayer being counted down to. Null when there is nothing left today.
  final PrayerSlot? slot;

  final Duration? remaining;

  /// True once the target time has passed — Home shows "it's time" until the
  /// schedule is reloaded for the next prayer.
  final bool elapsed;

  bool get isActive => slot != null && remaining != null;

  @override
  List<Object?> get props => [slot, remaining, elapsed];
}

/// Ticks once per second, in isolation.
///
/// Kept apart from `PrayerTimesBloc` on purpose: re-emitting the full prayer
/// list every second would rebuild the whole screen sixty times a minute.
/// This cubit emits only the target slot and the remaining duration.
@injectable
class NextPrayerCountdownCubit extends Cubit<CountdownState> {
  NextPrayerCountdownCubit(this._clock) : super(const CountdownState());

  final Clock _clock;

  Timer? _timer;
  DailyPrayerTimes? _times;

  /// Point the countdown at a schedule and start ticking.
  ///
  /// Safe to call repeatedly — the previous timer is always cancelled first,
  /// so a rapid sequence of loads cannot leave several timers running.
  void track(DailyPrayerTimes times) {
    _times = times;
    _timer?.cancel();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final times = _times;
    if (times == null) return;

    final now = _clock.now();
    final next = times.nextPrayerAt(now);

    if (next == null) {
      // Past Isha: this day's schedule has nothing left. The caller reloads
      // with tomorrow's schedule rather than this cubit guessing at it.
      emit(const CountdownState(elapsed: true));
      stop();
      return;
    }

    final remaining = next.time.difference(now);
    if (remaining.isNegative) {
      emit(CountdownState(slot: next.slot, elapsed: true));
      return;
    }

    emit(CountdownState(slot: next.slot, remaining: remaining));
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
