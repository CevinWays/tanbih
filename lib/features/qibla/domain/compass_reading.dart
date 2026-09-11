import 'package:equatable/equatable.dart';

/// Quality of the magnetometer's current calibration, as Android reports it.
enum CompassAccuracy {
  /// No magnetometer at all. The dial cannot work; show a bearing instead.
  unavailable,

  /// Readings are not trustworthy — the user needs to wave the phone in a
  /// figure of eight.
  unreliable,

  low,
  medium,
  high;

  bool get needsCalibration =>
      this == CompassAccuracy.unreliable || this == CompassAccuracy.low;

  /// Maps Android's SensorManager.SENSOR_STATUS_* values.
  static CompassAccuracy fromPlatform(int value) => switch (value) {
    3 => CompassAccuracy.high,
    2 => CompassAccuracy.medium,
    1 => CompassAccuracy.low,
    0 => CompassAccuracy.unreliable,
    _ => CompassAccuracy.unavailable,
  };
}

/// One heading sample, already corrected to true north.
class CompassReading extends Equatable {
  const CompassReading({
    required this.hasSensor,
    required this.accuracy,
    this.headingDegrees,
  });

  const CompassReading.unavailable()
    : hasSensor = false,
      accuracy = CompassAccuracy.unavailable,
      headingDegrees = null;

  final bool hasSensor;

  /// Degrees clockwise from **true** north. Null when there is no sensor.
  final double? headingDegrees;

  final CompassAccuracy accuracy;

  @override
  List<Object?> get props => [hasSensor, headingDegrees, accuracy];
}
