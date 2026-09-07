import 'package:dio/dio.dart';

import 'failures.dart';

/// Maps a [DioException] onto the app's `Failure` vocabulary.
///
/// Adapted from the same helper in lessworry-mobile. The status code is kept
/// on [ServerFailure] so callers can distinguish 4xx (surface to the user,
/// never retry) from 5xx (retryable).
Failure mapDioExceptionToFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure(message: 'Koneksi timeout');

    case DioExceptionType.connectionError:
      return const NetworkFailure();

    case DioExceptionType.badCertificate:
      return const ServerFailure(message: 'Sertifikat server tidak valid');

    case DioExceptionType.transformTimeout:
      // Decoding the payload took too long — a client-side problem, not a
      // connectivity one, so it must not be reported as offline.
      return const UnexpectedFailure(message: 'Gagal memproses respons');

    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      return ServerFailure(
        message: _messageFromResponse(e.response) ?? 'Server error',
        statusCode: code,
      );

    case DioExceptionType.cancel:
      return const ServerFailure(message: 'Permintaan dibatalkan');

    case DioExceptionType.unknown:
      // Dio wraps socket errors here when there is no route to host.
      final inner = e.error?.toString() ?? '';
      if (inner.contains('SocketException') ||
          inner.contains('Failed host lookup')) {
        return const NetworkFailure();
      }
      return UnexpectedFailure(message: e.message ?? '');
  }
}

/// Best-effort extraction of a human-readable message from an error body.
String? _messageFromResponse(Response<dynamic>? response) {
  final data = response?.data;
  if (data is Map) {
    for (final key in const ['message', 'error', 'detail']) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
  }
  if (data is String && data.isNotEmpty && data.length < 200) return data;
  return null;
}
