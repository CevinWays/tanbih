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
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio(gh<_i207.Talker>()));
    gh.lazySingleton<_i335.AppPreferencesLocalDataSource>(
      () => _i335.AppPreferencesLocalDataSourceImpl(
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i598.NetworkInfo>(
      () => _i598.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i431.LocaleCubit>(
      () => _i431.LocaleCubit(gh<_i335.AppPreferencesLocalDataSource>()),
    );
    gh.lazySingleton<_i65.ThemeCubit>(
      () => _i65.ThemeCubit(gh<_i335.AppPreferencesLocalDataSource>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i986.RegisterModule {}
