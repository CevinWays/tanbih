import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/di/injector.dart';
import 'core/services/app_context.dart';

/// Single startup path.
///
/// Order matters: the timezone database has to be loaded before anything can
/// build a `TZDateTime`, and DI has to be configured before the widget tree
/// resolves a bloc.
Future<void> bootstrap() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Hold the native splash across startup instead of flashing an empty frame
  // while the timezone database loads and DI is wired.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final timeZoneId = await _initTimeZone();
  await configureDependencies();

  // The data layer reads the device zone from here; see AppContext.
  sl<AppContext>().deviceTimeZoneId = timeZoneId;

  final talker = sl<Talker>();
  Bloc.observer = TalkerBlocObserver(talker: talker);

  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack);
    if (kDebugMode) FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  runApp(TanbihApp());
  FlutterNativeSplash.remove();
}

/// Loads the tz database, pins the local zone, and returns its IANA name.
///
/// Every scheduled notification is built as a `TZDateTime` in this zone, so
/// DST transitions and timezone changes shift the schedule correctly instead
/// of silently drifting.
Future<String> _initTimeZone() async {
  tz_data.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
    return info.identifier;
  } catch (_) {
    // Unknown or unmappable zone: tz defaults to UTC, which would shift every
    // prayer time. Fall back to the device's current UTC offset instead.
    final fallback = _zoneNameForOffset(DateTime.now().timeZoneOffset);
    tz.setLocalLocation(tz.getLocation(fallback));
    return fallback;
  }
}

/// Best-effort zone for a raw UTC offset, used only when the platform cannot
/// report an IANA identifier. Covers the Indonesian zones first.
String _zoneNameForOffset(Duration offset) => switch (offset.inHours) {
  7 => 'Asia/Jakarta',
  8 => 'Asia/Makassar',
  9 => 'Asia/Jayapura',
  _ => 'UTC',
};
