import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../network/api_client.dart';

/// Registration for third-party types that cannot carry an `@injectable`
/// annotation themselves.
@module
abstract class RegisterModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  Talker get talker => TalkerFlutter.init();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  FlutterLocalNotificationsPlugin get localNotifications =>
      FlutterLocalNotificationsPlugin();

  /// One player for in-app preview and foreground playback. Background adhan
  /// goes through the native service instead, not through this.
  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer();

  @lazySingleton
  Dio dio(Talker talker) =>
      ApiClient.create(talker: talker, appVersion: _appVersion);

  /// Kept in sync with `version:` in pubspec.yaml. Only used for the
  /// User-Agent header, so a stale value is cosmetic rather than breaking.
  static const String _appVersion = '1.0.0';
}
