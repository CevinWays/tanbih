import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injector.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/routes/app_router.dart';
import 'core/services/prayer_schedule_coordinator.dart';
import 'core/styles/styles.dart';
import 'core/widgets/schedule_sync.dart';
import 'features/location/presentation/bloc/location_bloc.dart';
import 'features/notification/presentation/bloc/notification_settings_cubit.dart';
import 'features/prayer_times/presentation/bloc/calculation_settings_cubit.dart';
import 'features/location/presentation/bloc/location_event.dart';
import 'features/settings/presentation/bloc/locale_cubit.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';

class TanbihApp extends StatelessWidget {
  TanbihApp({super.key});

  final AppRouter _router = sl<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<LocaleCubit>()),
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(
          value: sl<LocationBloc>()..add(const LocationStartupRequested()),
        ),
        BlocProvider.value(value: sl<CalculationSettingsCubit>()..load()),
        BlocProvider.value(value: sl<NotificationSettingsCubit>()..load()),
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return ScheduleSync(
                coordinator: sl<PrayerScheduleCoordinator>(),
                child: MaterialApp.router(
                  title: 'Tanbih',
                  debugShowCheckedModeBanner: false,
                  routerConfig: _router.config(),
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  locale: locale,
                  supportedLocales: LocaleCubit.supported,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
