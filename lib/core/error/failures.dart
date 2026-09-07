import 'package:equatable/equatable.dart';

/// Base type for every recoverable error surfaced to the domain layer.
///
/// Exceptions never cross the data/domain boundary — repository
/// implementations are the only place that turns an exception into a
/// [Failure]. See CLAUDE.md § Use Cases & Error Handling.
abstract class Failure extends Equatable {
  const Failure({this.message = ''});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Prayer time calculation could not be produced (invalid coordinates,
/// undefined prayer at extreme latitude, corrupt settings).
class CalculationFailure extends Failure {
  const CalculationFailure({super.message = 'Gagal menghitung waktu shalat'});
}

/// Device location could not be resolved. [isTimeout] lets callers decide
/// between falling back to cache and prompting for a manual city.
class LocationFailure extends Failure {
  const LocationFailure({super.message = '', this.isTimeout = false});

  final bool isTimeout;

  @override
  List<Object?> get props => [message, isTimeout];
}

/// A runtime permission was refused. [isPermanentlyDenied] means the OS will
/// no longer show the prompt, so the UI must deep link into app settings.
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = '',
    this.isPermanentlyDenied = false,
  });

  final bool isPermanentlyDenied;

  @override
  List<Object?> get props => [message, isPermanentlyDenied];
}

/// Scheduling a notification or an exact alarm failed.
///
/// [exactAlarmDenied] is the case that matters most: on API 34+ the user can
/// revoke exact-alarm access, and the scheduler must degrade to inexact
/// delivery rather than silently dropping the reminder.
class NotificationFailure extends Failure {
  const NotificationFailure({
    super.message = '',
    this.exactAlarmDenied = false,
  });

  final bool exactAlarmDenied;

  @override
  List<Object?> get props => [message, exactAlarmDenied];
}

/// Adhan audio could not be played, downloaded, or verified.
class AudioFailure extends Failure {
  const AudioFailure({super.message = ''});
}

/// Auto-silent could not be applied. [policyAccessDenied] means the app lacks
/// Do Not Disturb access and the user must grant it from system settings.
class SilentModeFailure extends Failure {
  const SilentModeFailure({
    super.message = '',
    this.policyAccessDenied = false,
  });

  final bool policyAccessDenied;

  @override
  List<Object?> get props => [message, policyAccessDenied];
}

/// Compass/qibla could not be read. [sensorUnavailable] means the device has
/// no magnetometer, so the UI must fall back to a numeric bearing.
class QiblaFailure extends Failure {
  const QiblaFailure({super.message = '', this.sensorUnavailable = false});

  final bool sensorUnavailable;

  @override
  List<Object?> get props => [message, sensorUnavailable];
}

/// No usable connection. Network is always optional in this app, so callers
/// treat this as "fall back to local", never as a fatal error.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Tidak ada koneksi internet'});
}

/// Upstream responded with an error status.
class ServerFailure extends Failure {
  const ServerFailure({super.message = '', this.statusCode});

  /// HTTP status from the upstream response when the failure came from a
  /// `badResponse` DioException. Null for parse errors, cancellations, and
  /// unknown failures.
  final int? statusCode;

  /// 4xx — the request itself is wrong. Surface it; never retry.
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// 5xx — upstream problem. Eligible for retry.
  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Reading or writing local storage failed.
class CacheFailure extends Failure {
  const CacheFailure({super.message = ''});
}

/// Anything unclassified. Always logged before being emitted.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'Terjadi kesalahan tak terduga'});
}
