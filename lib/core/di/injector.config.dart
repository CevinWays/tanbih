// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:just_audio/just_audio.dart' as _i501;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:talker_flutter/talker_flutter.dart' as _i207;
import 'package:tanbih/core/di/register_module.dart' as _i986;
import 'package:tanbih/core/network/network_info.dart' as _i598;
import 'package:tanbih/core/routes/app_router.dart' as _i208;
import 'package:tanbih/core/services/clock.dart' as _i457;
import 'package:tanbih/features/prayer_times/data/datasources/adhan_calculator_data_source.dart'
    as _i237;
import 'package:tanbih/features/prayer_times/data/datasources/calculation_settings_local_data_source.dart'
    as _i647;
import 'package:tanbih/features/prayer_times/data/datasources/hijri_data_source.dart'
    as _i259;
import 'package:tanbih/features/prayer_times/data/repositories/prayer_times_repository_impl.dart'
    as _i1064;
import 'package:tanbih/features/prayer_times/domain/repositories/prayer_times_repository.dart'
    as _i652;
import 'package:tanbih/features/prayer_times/domain/usecases/get_calculation_settings.dart'
    as _i34;
import 'package:tanbih/features/prayer_times/domain/usecases/get_prayer_times_for_date.dart'
    as _i710;
import 'package:tanbih/features/prayer_times/domain/usecases/get_prayer_times_range.dart'
    as _i812;
import 'package:tanbih/features/prayer_times/domain/usecases/get_today_prayer_times.dart'
    as _i378;
import 'package:tanbih/features/prayer_times/domain/usecases/save_calculation_settings.dart'
    as _i105;
import 'package:tanbih/features/prayer_times/presentation/bloc/next_prayer_countdown_cubit.dart'
    as _i913;
import 'package:tanbih/features/prayer_times/presentation/bloc/prayer_times_bloc.dart'
    as _i267;
import 'package:tanbih/features/settings/data/datasources/app_preferences_local_data_source.dart'
    as _i335;
import 'package:tanbih/features/settings/presentation/bloc/locale_cubit.dart'
    as _i431;
import 'package:tanbih/features/settings/presentation/bloc/theme_cubit.dart'
    as _i65;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i208.AppRouter>(() => _i208.AppRouter());
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i207.Talker>(() => registerModule.talker);
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => registerModule.localNotifications,
    );
    gh.lazySingleton<_i501.AudioPlayer>(() => registerModule.audioPlayer);
    gh.lazySingleton<_i457.Clock>(() => const _i457.SystemClock());
    gh.lazySingleton<_i237.AdhanCalculatorDataSource>(
      () => const _i237.AdhanCalculatorDataSourceImpl(),
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio(gh<_i207.Talker>()));
    gh.lazySingleton<_i259.HijriDataSource>(() => _i259.HijriDataSourceImpl());
    gh.lazySingleton<_i647.CalculationSettingsLocalDataSource>(
      () => _i647.CalculationSettingsLocalDataSourceImpl(
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i335.AppPreferencesLocalDataSource>(
      () => _i335.AppPreferencesLocalDataSourceImpl(
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i598.NetworkInfo>(
      () => _i598.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.factory<_i913.NextPrayerCountdownCubit>(
      () => _i913.NextPrayerCountdownCubit(gh<_i457.Clock>()),
    );
    gh.lazySingleton<_i652.PrayerTimesRepository>(
      () => _i1064.PrayerTimesRepositoryImpl(
        gh<_i237.AdhanCalculatorDataSource>(),
        gh<_i259.HijriDataSource>(),
        gh<_i647.CalculationSettingsLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i431.LocaleCubit>(
      () => _i431.LocaleCubit(gh<_i335.AppPreferencesLocalDataSource>()),
    );
    gh.lazySingleton<_i65.ThemeCubit>(
      () => _i65.ThemeCubit(gh<_i335.AppPreferencesLocalDataSource>()),
    );
    gh.factory<_i34.GetCalculationSettings>(
      () => _i34.GetCalculationSettings(gh<_i652.PrayerTimesRepository>()),
    );
    gh.factory<_i710.GetPrayerTimesForDate>(
      () => _i710.GetPrayerTimesForDate(gh<_i652.PrayerTimesRepository>()),
    );
    gh.factory<_i812.GetPrayerTimesRange>(
      () => _i812.GetPrayerTimesRange(gh<_i652.PrayerTimesRepository>()),
    );
    gh.factory<_i105.SaveCalculationSettings>(
      () => _i105.SaveCalculationSettings(gh<_i652.PrayerTimesRepository>()),
    );
    gh.factory<_i378.GetTodayPrayerTimes>(
      () => _i378.GetTodayPrayerTimes(
        gh<_i652.PrayerTimesRepository>(),
        gh<_i457.Clock>(),
      ),
    );
    gh.factory<_i267.PrayerTimesBloc>(
      () => _i267.PrayerTimesBloc(
        gh<_i710.GetPrayerTimesForDate>(),
        gh<_i34.GetCalculationSettings>(),
        gh<_i105.SaveCalculationSettings>(),
        gh<_i457.Clock>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i986.RegisterModule {}
