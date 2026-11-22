import 'package:equatable/equatable.dart';

/// Where the Kaaba is from here, and how far.
class QiblaSummary extends Equatable {
  const QiblaSummary({required this.bearingDegrees, required this.distanceKm});

  /// Clockwise from true north.
  final double bearingDegrees;

  final double distanceKm;

  @override
  List<Object?> get props => [bearingDegrees, distanceKm];
}
