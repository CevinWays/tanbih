import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanbih/core/di/injector.dart';
import 'package:tanbih/core/routes/app_router.dart';
import 'package:tanbih/core/services/notification_service.dart';
import 'package:tanbih/core/services/prayer_schedule_coordinator.dart';
import 'package:tanbih/features/location/presentation/bloc/location_bloc.dart';
import 'package:tanbih/features/notification/presentation/bloc/notification_settings_cubit.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/calculation_settings_cubit.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/monthly_schedule_cubit.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/next_prayer_countdown_cubit.dart';
import 'package:tanbih/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:tanbih/features/settings/presentation/bloc/locale_cubit.dart';
import 'package:tanbih/features/settings/presentation/bloc/theme_cubit.dart';

/// Resolves everything the app resolves at startup.
///
/// Added after a missing `AssetBundle` registration shipped past a green
/// suite, a clean analyze, and a successful build, then crashed the app on
/// its first frame. Unit tests inject their dependencies by hand, so they
/// never exercise the container — this does.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies();
  });

  tearDown(() => sl.reset());

  test('every type the widget tree resolves is registered', () {
    expect(sl<AppRouter>(), isNotNull);
    expect(sl<LocaleCubit>(), isNotNull);
    expect(sl<ThemeCubit>(), isNotNull);
    expect(sl<LocationBloc>(), isNotNull);
    expect(sl<CalculationSettingsCubit>(), isNotNull);
    expect(sl<NotificationSettingsCubit>(), isNotNull);
    expect(sl<PrayerTimesBloc>(), isNotNull);
    expect(sl<NextPrayerCountdownCubit>(), isNotNull);
    expect(sl<MonthlyScheduleCubit>(), isNotNull);
    expect(sl<PrayerScheduleCoordinator>(), isNotNull);
    expect(sl<NotificationService>(), isNotNull);
  });

  test('resolving a bloc pulls its whole dependency graph', () {
    // The AssetBundle failure surfaced through this chain: LocationBloc ->
    // SearchCity -> repository -> CitySearchLocalDataSource -> AssetBundle.
    expect(() => sl<LocationBloc>(), returnsNormally);
  });

  test('singletons really are shared', () {
    // The scheduler and the settings screens have to see the same cubit, or
    // a settings change never reaches the schedule.
    expect(
      identical(sl<CalculationSettingsCubit>(), sl<CalculationSettingsCubit>()),
      isTrue,
    );
    expect(identical(sl<LocationBloc>(), sl<LocationBloc>()), isTrue);
  });
}
