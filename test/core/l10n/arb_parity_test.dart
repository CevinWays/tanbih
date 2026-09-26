import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps the two translations in step.
///
/// A key added to one file and forgotten in the other does not fail the
/// build — gen-l10n falls back to the template — so it ships as Indonesian
/// text inside an English app, or the other way round. Nothing catches that
/// except reading every screen in both languages.
void main() {
  Map<String, dynamic> load(String locale) =>
      jsonDecode(File('lib/core/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;

  bool isMessage(String key) => !key.startsWith('@');

  late Map<String, dynamic> id;
  late Map<String, dynamic> en;

  setUpAll(() {
    id = load('id');
    en = load('en');
  });

  test('both locales define exactly the same keys', () {
    final idKeys = id.keys.where(isMessage).toSet();
    final enKeys = en.keys.where(isMessage).toSet();

    expect(
      idKeys.difference(enKeys),
      isEmpty,
      reason: 'missing from app_en.arb',
    );
    expect(
      enKeys.difference(idKeys),
      isEmpty,
      reason: 'missing from app_id.arb',
    );
  });

  test('no message is left empty', () {
    for (final entry in {...id, ...en}.entries) {
      if (!isMessage(entry.key)) continue;
      expect(
        (entry.value as String).trim(),
        isNotEmpty,
        reason: '${entry.key} is blank',
      );
    }
  });

  test('placeholders match between the two languages', () {
    // "{minutes} menit" translated as "{mins} min" compiles, then throws at
    // runtime on the locale nobody tested.
    final pattern = RegExp(r'\{(\w+)\}');

    for (final key in id.keys.where(isMessage)) {
      if (!en.containsKey(key)) continue;

      final idSlots = pattern
          .allMatches(id[key] as String)
          .map((m) => m.group(1))
          .toSet();
      final enSlots = pattern
          .allMatches(en[key] as String)
          .map((m) => m.group(1))
          .toSet();

      expect(idSlots, enSlots, reason: 'placeholder mismatch in $key');
    }
  });

  test('every placeholder is declared in the template', () {
    // gen-l10n needs the @key metadata to know a placeholder's type;
    // without it the generated method takes Object and formats badly.
    final pattern = RegExp(r'\{(\w+)\}');

    for (final key in id.keys.where(isMessage)) {
      final slots = pattern.allMatches(id[key] as String);
      if (slots.isEmpty) continue;

      final meta = id['@$key'];
      expect(
        meta,
        isNotNull,
        reason: '$key uses placeholders but has no @$key metadata',
      );

      final declared = ((meta as Map)['placeholders'] as Map).keys.toSet();
      expect(
        slots.map((m) => m.group(1)).toSet(),
        declared,
        reason: 'placeholder metadata for $key does not match the message',
      );
    }
  });

  test('the two files are not accidentally identical', () {
    // Prayer names genuinely differ between the languages, so a file copied
    // over the other would show up here.
    expect(id['prayerFajr'], 'Subuh');
    expect(en['prayerFajr'], 'Fajr');
  });
}
