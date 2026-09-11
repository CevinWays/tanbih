import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/notification_sound.dart';
import '../../domain/entities/prayer_notification_pref.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_settings_local_data_source.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._local, this._service);

  final NotificationSettingsLocalDataSource _local;
  final NotificationService _service;

  @override
  Future<Either<Failure, NotificationSettings>> getSettings() async {
    try {
      return Right(_local.read());
    } on Object catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSettings(
    NotificationSettings settings,
  ) async {
    try {
      await _local.write(settings);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPermission() async {
    try {
      return Right(await _service.hasPermission());
    } on Object catch (e) {
      return Left(NotificationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      return Right(await _service.requestPermission());
    } on Object catch (e) {
      return Left(NotificationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canScheduleExactAlarms() async {
    try {
      return Right(await _service.canScheduleExactAlarms());
    } on Object catch (e) {
      return Left(
        NotificationFailure(message: e.toString(), exactAlarmDenied: true),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> openExactAlarmSettings() async {
    try {
      await _service.openExactAlarmSettings();
      return const Right(unit);
    } on Object catch (e) {
      return Left(NotificationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendTestNotification(
    NotificationSound sound,
  ) async {
    try {
      await _service.showNow(
        title: 'Tanbih',
        body: 'Contoh notifikasi waktu shalat',
        sound: sound,
      );
      return const Right(unit);
    } on Object catch (e) {
      return Left(NotificationFailure(message: e.toString()));
    }
  }
}
