import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/location/presentation/bloc/location_bloc.dart';
import '../../features/location/presentation/bloc/location_state.dart';
import '../../features/notification/presentation/bloc/notification_settings_cubit.dart';
import '../../features/prayer_times/presentation/bloc/calculation_settings_cubit.dart';
import '../services/prayer_schedule_coordinator.dart';

/// Keeps the scheduled notifications in step with everything they depend on.
///
/// Wraps the app so the rebuild happens once, centrally, instead of every
/// screen that can change a setting having to remember to trigger it. The
/// triggers are: a new location, changed calculation settings, changed
/// notification settings, and the app returning to the foreground — which
/// is also how a day rollover gets picked up.
class ScheduleSync extends StatefulWidget {
  const ScheduleSync({
    required this.coordinator,
    required this.child,
    super.key,
  });

  final PrayerScheduleCoordinator coordinator;
  final Widget child;

  @override
  State<ScheduleSync> createState() => _ScheduleSyncState();
}

class _ScheduleSyncState extends State<ScheduleSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync(force: false);
  }

  void _sync({required bool force}) {
    final location = context.read<LocationBloc>().state.location;
    if (location == null) return;

    if (!force &&
        !widget.coordinator.needsRescheduleFor(
          location.latitude,
          location.longitude,
        )) {
      return;
    }

    // Fire and forget: nothing on screen waits for the schedule, and a
    // failure here must not block the UI.
    unawaited(
      widget.coordinator.reschedule(
        latitude: location.latitude,
        longitude: location.longitude,
        timeZoneId: location.timeZoneId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LocationBloc, LocationState>(
          listenWhen: (previous, current) =>
              current.location != null && previous.location != current.location,
          listener: (_, _) => _sync(force: false),
        ),
        // A settings change always rebuilds, however small: the times
        // themselves moved, so distance-based skipping does not apply.
        BlocListener<CalculationSettingsCubit, CalculationSettingsState>(
          listenWhen: (previous, current) =>
              previous.settings != current.settings,
          listener: (_, _) => _sync(force: true),
        ),
        BlocListener<NotificationSettingsCubit, NotificationSettingsState>(
          listenWhen: (previous, current) =>
              previous.settings != current.settings ||
              previous.hasPermission != current.hasPermission,
          listener: (_, _) => _sync(force: true),
        ),
      ],
      child: widget.child,
    );
  }
}
