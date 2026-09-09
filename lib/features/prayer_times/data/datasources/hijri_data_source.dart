import 'package:hijri/hijri_calendar.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/hijri_date.dart';

/// Hijri conversion. The only place that imports the `hijri` package.
abstract class HijriDataSource {
  /// Converts [date], shifted by [offsetDays] first.
  ///
  /// The offset is applied to the Gregorian input rather than to the
  /// resulting Hijri day number, because `hijri` has no offset API and
  /// shifting the output would break month-length boundaries.
  HijriDate convert({
    required DateTime date,
    required int offsetDays,
    required String languageCode,
  });
}

@LazySingleton(as: HijriDataSource)
class HijriDataSourceImpl implements HijriDataSource {
  HijriDataSourceImpl();

  /// `hijri` ships Arabic and English. Indonesian month names are added here
  /// so the Home header reads naturally for the default locale.
  static const Map<int, String> _indonesianMonths = {
    1: 'Muharram',
    2: 'Safar',
    3: "Rabi'ul Awal",
    4: "Rabi'ul Akhir",
    5: 'Jumadil Awal',
    6: 'Jumadil Akhir',
    7: 'Rajab',
    8: "Sya'ban",
    9: 'Ramadhan',
    10: 'Syawal',
    11: 'Dzulqa\'dah',
    12: 'Dzulhijjah',
  };

  static const Map<int, String> _englishMonths = {
    1: 'Muharram',
    2: 'Safar',
    3: "Rabi' al-Awwal",
    4: "Rabi' al-Thani",
    5: 'Jumada al-Awwal',
    6: 'Jumada al-Thani',
    7: 'Rajab',
    8: "Sha'ban",
    9: 'Ramadan',
    10: 'Shawwal',
    11: "Dhu al-Qi'dah",
    12: 'Dhu al-Hijjah',
  };

  @override
  HijriDate convert({
    required DateTime date,
    required int offsetDays,
    required String languageCode,
  }) {
    final shifted = date.add(Duration(days: offsetDays));
    final hijri = HijriCalendar.fromDate(shifted);
    final months = languageCode == 'en' ? _englishMonths : _indonesianMonths;

    return HijriDate(
      year: hijri.hYear,
      month: hijri.hMonth,
      day: hijri.hDay,
      monthName: months[hijri.hMonth] ?? '',
    );
  }
}
