import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../features/qibla/domain/compass_port.dart';
import '../../features/qibla/domain/compass_reading.dart';

/// Bridges the native compass stream.
@LazySingleton(as: CompassPort)
class CompassChannel implements CompassPort {
  const CompassChannel();

  static const EventChannel _channel = EventChannel('com.cevin.tanbih/compass');

  @override
  Stream<CompassReading> readings({
    required double latitude,
    required double longitude,
  }) {
    // Only Android has the native handler; elsewhere the screen falls back
    // to the numeric bearing rather than showing a dial that never moves.
    if (!Platform.isAndroid) {
      return Stream.value(const CompassReading.unavailable());
    }

    return _channel
        .receiveBroadcastStream({'latitude': latitude, 'longitude': longitude})
        .map((event) {
          final map = (event as Map).cast<String, dynamic>();
          return CompassReading(
            hasSensor: map['hasSensor'] as bool? ?? false,
            headingDegrees: (map['heading'] as num?)?.toDouble(),
            accuracy: CompassAccuracy.fromPlatform(
              (map['accuracy'] as num?)?.toInt() ?? -1,
            ),
          );
        })
        .handleError((Object _) => const CompassReading.unavailable());
  }
}
