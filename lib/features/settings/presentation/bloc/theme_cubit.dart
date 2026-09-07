import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/app_preferences_local_data_source.dart';

/// Light / dark / follow-system.
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_read(_prefs));

  final AppPreferencesLocalDataSource _prefs;

  static ThemeMode _read(AppPreferencesLocalDataSource prefs) =>
      _parse(prefs.getThemeModeName());

  static ThemeMode _parse(String name) => switch (name) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeModeName(mode.name);
    emit(mode);
  }
}
