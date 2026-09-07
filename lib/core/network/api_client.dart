import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../config/app_config.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/header_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Builds the single [Dio] instance the app uses.
///
/// Registered as a lazy singleton in `register_module.dart`. Nothing outside
/// a remote data source may hold a reference to it.
///
/// Interceptor order matters: headers first, then error mapping (so the retry
/// step sees a mapped failure), then retry, then logging last so it records
/// the final outcome.
abstract final class ApiClient {
  static Dio create({required Talker talker, required String appVersion}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.remoteBaseUrl,
        connectTimeout: AppConfig.httpConnectTimeout,
        receiveTimeout: AppConfig.httpReceiveTimeout,
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      HeaderInterceptor(
        appVersion: appVersion,
        platformLabel: _platformLabel(),
      ),
      ErrorInterceptor(),
      RetryInterceptor(dio: dio),
    ]);

    // Logging is debug-only: request/response bodies must never end up in a
    // release build's logs.
    if (kDebugMode) {
      dio.interceptors.add(
        TalkerDioLogger(
          talker: talker,
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: false,
            printResponseHeaders: false,
            printResponseData: false,
          ),
        ),
      );
    }

    return dio;
  }

  static String _platformLabel() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android ${Platform.operatingSystemVersion}';
    if (Platform.isIOS) return 'iOS ${Platform.operatingSystemVersion}';
    return Platform.operatingSystem;
  }
}
