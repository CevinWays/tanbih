import 'package:equatable/equatable.dart';

/// A Hijri date, already corrected by the user's day offset.
class HijriDate extends Equatable {
  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.monthName,
  });

  final int year;
  final int month;
  final int day;

  /// Localized month name, resolved when the date was built.
  final String monthName;

  /// Ramadan is the 9th month. Drives the Umm al-Qura Isha correction.
  bool get isRamadan => month == 9;

  @override
  List<Object?> get props => [year, month, day, monthName];

  @override
  String toString() => '$day $monthName $year';
}
