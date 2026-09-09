import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/app_context.dart';
import '../../data/datasources/app_preferences_local_data_source.dart';

/// Active locale. `null` means follow the system, which is the default.
///
/// Simple enough to be a Cubit — no event stream needed.
@lazySingleton
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs, this._appContext) : super(_read(_prefs)) {
    _syncAppContext(state);
  }

  final AppPreferencesLocalDataSource _prefs;
  final AppContext _appContext;

  /// Locales the app ships. Indonesian is first because it is the fallback.
  static const List<Locale> supported = [Locale('id'), Locale('en')];

  static Locale? _read(AppPreferencesLocalDataSource prefs) {
    final code = prefs.getLocaleCode();
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    // Applied before persisting: the language the data layer uses must
    // follow the UI immediately, and must not depend on the write
    // succeeding.
    _syncAppContext(locale);
    emit(locale);
    await _prefs.setLocaleCode(locale?.languageCode);
  }

  /// Keeps the data layer's language in step, so reverse-geocoded place
  /// names and Hijri month names follow the app's language.
  ///
  /// Following the system means resolving it here: the data layer has no
  /// `BuildContext` to ask.
  void _syncAppContext(Locale? locale) {
    final code =
        locale?.languageCode ?? PlatformDispatcher.instance.locale.languageCode;
    _appContext.languageCode = supported.any((l) => l.languageCode == code)
        ? code
        : 'id';
  }

  Future<void> followSystem() => setLocale(null);
}
