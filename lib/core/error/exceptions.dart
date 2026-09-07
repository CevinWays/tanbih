/// Exceptions thrown inside the data layer only.
///
/// They never reach the domain layer — repository implementations catch them
/// and map them to a `Failure`. See CLAUDE.md § Use Cases & Error Handling.
class ServerException implements Exception {
  const ServerException({this.message = '', this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException({this.message = 'No connection'});

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  const CacheException({this.message = ''});

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class LocationException implements Exception {
  const LocationException({this.message = '', this.isTimeout = false});

  final String message;
  final bool isTimeout;

  @override
  String toString() => 'LocationException(timeout: $isTimeout): $message';
}

class PermissionException implements Exception {
  const PermissionException({
    this.message = '',
    this.isPermanentlyDenied = false,
  });

  final String message;
  final bool isPermanentlyDenied;

  @override
  String toString() => 'PermissionException: $message';
}

class CalculationException implements Exception {
  const CalculationException({this.message = ''});

  final String message;

  @override
  String toString() => 'CalculationException: $message';
}

class AudioException implements Exception {
  const AudioException({this.message = ''});

  final String message;

  @override
  String toString() => 'AudioException: $message';
}

/// A platform channel call into the native alarm / silent-mode layer failed.
class PlatformChannelException implements Exception {
  const PlatformChannelException({this.message = '', this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'PlatformChannelException($code): $message';
}
