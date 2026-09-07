import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injector.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/routes/app_router.dart';
import 'core/styles/styles.dart';
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
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                title: 'Tanbih',
                debugShowCheckedModeBanner: false,
                routerConfig: _router.config(),
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                locale: locale,
                supportedLocales: LocaleCubit.supported,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
              );
            },
          );
        },
      ),
    );
  }
}
