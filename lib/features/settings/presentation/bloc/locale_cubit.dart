import 'dart:ui' show Locale;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/app_preferences_local_data_source.dart';

/// Active locale. `null` means follow the system, which is the default.
///
/// Simple enough to be a Cubit — no event stream needed.
@lazySingleton
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs) : super(_read(_prefs));

  final AppPreferencesLocalDataSource _prefs;

  /// Locales the app ships. Indonesian is first because it is the fallback.
  static const List<Locale> supported = [Locale('id'), Locale('en')];

  static Locale? _read(AppPreferencesLocalDataSource prefs) {
    final code = prefs.getLocaleCode();
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    await _prefs.setLocaleCode(locale?.languageCode);
    emit(locale);
  }

  Future<void> followSystem() => setLocale(null);
}
