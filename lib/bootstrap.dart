import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/di/injector.dart';

/// Single startup path.
///
/// Order matters: the timezone database has to be loaded before anything can
/// build a `TZDateTime`, and DI has to be configured before the widget tree
/// resolves a bloc.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initTimeZone();
  await configureDependencies();

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
}

/// Loads the tz database and pins the local zone to the device's zone.
///
/// Every scheduled notification is built as a `TZDateTime` in this zone, so
/// DST transitions and timezone changes shift the schedule correctly instead
/// of silently drifting.
Future<void> _initTimeZone() async {
  tz_data.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } catch (_) {
    // Unknown or unmappable zone: tz defaults to UTC, which would shift every
    // prayer time. Fall back to the device's current UTC offset instead.
    final offset = DateTime.now().timeZoneOffset;
    tz.setLocalLocation(tz.getLocation(_zoneNameForOffset(offset)));
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
