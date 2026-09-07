import 'package:dio/dio.dart';

/// Adds the identifying headers every outbound request needs.
///
/// A descriptive `User-Agent` is not optional: Nominatim's terms of use
/// require one, and requests without it get blocked.
class HeaderInterceptor extends Interceptor {
  HeaderInterceptor({required this.appVersion, required this.platformLabel});

  final String appVersion;
  final String platformLabel;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('Accept', () => 'application/json');
    options.headers.putIfAbsent(
      'User-Agent',
      () => 'Tanbih/$appVersion ($platformLabel; +https://github.com/cevin)',
    );
    handler.next(options);
  }
}
