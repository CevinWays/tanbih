import 'compass_reading.dart';

/// Device heading, corrected to true north.
abstract class CompassPort {
  /// Starts streaming for a position.
  ///
  /// The position is required because the magnetic declination that turns a
  /// magnetic reading into a true one depends on where you are.
  Stream<CompassReading> readings({
    required double latitude,
    required double longitude,
  });
}
