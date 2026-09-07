import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tanbih/features/settings/data/datasources/app_preferences_local_data_source.dart';
import 'package:tanbih/features/settings/presentation/bloc/locale_cubit.dart';
import 'package:tanbih/features/settings/presentation/bloc/theme_cubit.dart';

class MockPrefs extends Mock implements AppPreferencesLocalDataSource {}

void main() {
  late MockPrefs prefs;

  setUp(() {
    prefs = MockPrefs();
    when(() => prefs.setLocaleCode(any())).thenAnswer((_) async {});
    when(() => prefs.setThemeModeName(any())).thenAnswer((_) async {});
  });

  group('LocaleCubit', () {
    test('starts as null (follow system) when nothing is stored', () {
      when(() => prefs.getLocaleCode()).thenReturn(null);
      expect(LocaleCubit(prefs).state, isNull);
    });

    test('restores the stored locale', () {
      when(() => prefs.getLocaleCode()).thenReturn('en');
      expect(LocaleCubit(prefs).state, const Locale('en'));
    });

    blocTest<LocaleCubit, Locale?>(
      'setLocale emits and persists the language code',
      setUp: () => when(() => prefs.getLocaleCode()).thenReturn(null),
      build: () => LocaleCubit(prefs),
      act: (cubit) => cubit.setLocale(const Locale('en')),
      expect: () => [const Locale('en')],
      verify: (_) => verify(() => prefs.setLocaleCode('en')).called(1),
    );

    blocTest<LocaleCubit, Locale?>(
      'followSystem clears the stored override',
      setUp: () => when(() => prefs.getLocaleCode()).thenReturn('en'),
      build: () => LocaleCubit(prefs),
      act: (cubit) => cubit.followSystem(),
      expect: () => [null],
      verify: (_) => verify(() => prefs.setLocaleCode(null)).called(1),
    );

    test('ships Indonesian first so it is the fallback locale', () {
      expect(LocaleCubit.supported.first, const Locale('id'));
      expect(LocaleCubit.supported, contains(const Locale('en')));
    });
  });

  group('ThemeCubit', () {
    test('defaults to following the system', () {
      when(() => prefs.getThemeModeName()).thenReturn('system');
      expect(ThemeCubit(prefs).state, ThemeMode.system);
    });

    test('an unrecognised stored value falls back to system', () {
      when(() => prefs.getThemeModeName()).thenReturn('sepia');
      expect(ThemeCubit(prefs).state, ThemeMode.system);
    });

    blocTest<ThemeCubit, ThemeMode>(
      'setThemeMode emits and persists',
      setUp: () => when(() => prefs.getThemeModeName()).thenReturn('system'),
      build: () => ThemeCubit(prefs),
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => [ThemeMode.dark],
      verify: (_) => verify(() => prefs.setThemeModeName('dark')).called(1),
    );
  });
}
