import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_notification_pref.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationSettings>> getSettings();

  Future<Either<Failure, Unit>> saveSettings(NotificationSettings settings);

  /// Whether the OS will let the app post notifications at all.
  Future<Either<Failure, bool>> hasPermission();

  /// Asks for the runtime notification permission (Android 13+).
  Future<Either<Failure, bool>> requestPermission();

  /// Whether exact alarms are allowed. On Android 14+ this is revocable, and
  /// losing it means reminders arrive late rather than not at all.
  Future<Either<Failure, bool>> canScheduleExactAlarms();

  /// Opens the system screen for granting exact alarms.
  Future<Either<Failure, Unit>> openExactAlarmSettings();

  /// Posts a notification immediately, so the user can hear what they chose.
  Future<Either<Failure, Unit>> sendTestNotification();
}
