import 'package:equatable/equatable.dart';

/// Where the observer is.
class QiblaParams extends Equatable {
  const QiblaParams({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}
