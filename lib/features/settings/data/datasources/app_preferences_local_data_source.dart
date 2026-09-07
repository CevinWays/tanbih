import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence for app-shell preferences (locale, theme).
///
/// Calculation, notification, and silent-mode settings each own their own
/// data source; this one is only for the shell.
abstract class AppPreferencesLocalDataSource {
  /// Null means "follow the system locale".
  String? getLocaleCode();
  Future<void> setLocaleCode(String? code);

  /// One of `system`, `light`, `dark`.
  String getThemeModeName();
  Future<void> setThemeModeName(String name);

  bool getOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool value);
}

@LazySingleton(as: AppPreferencesLocalDataSource)
class AppPreferencesLocalDataSourceImpl
    implements AppPreferencesLocalDataSource {
  AppPreferencesLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyLocale = 'app.locale';
  static const String _keyThemeMode = 'app.theme_mode';
  static const String _keyOnboarding = 'app.onboarding_completed';

  @override
  String? getLocaleCode() => _prefs.getString(_keyLocale);

  @override
  Future<void> setLocaleCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_keyLocale);
    } else {
      await _prefs.setString(_keyLocale, code);
    }
  }

  @override
  String getThemeModeName() => _prefs.getString(_keyThemeMode) ?? 'system';

  @override
  Future<void> setThemeModeName(String name) =>
      _prefs.setString(_keyThemeMode, name);

  @override
  bool getOnboardingCompleted() => _prefs.getBool(_keyOnboarding) ?? false;

  @override
  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(_keyOnboarding, value);
}
