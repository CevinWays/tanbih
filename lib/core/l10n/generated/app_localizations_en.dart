// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tanbih';

  @override
  String get appTagline => 'Prayer times & adhan reminder';

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerJumuah => 'Jumu\'ah';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get nextPrayerLabel => 'Next prayer';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String countdownHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String countdownMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get prayerTimeNow => 'It\'s time for prayer';

  @override
  String get locationCurrent => 'Current location';

  @override
  String get locationTapToChange => 'Tap to change location';

  @override
  String get locationUnknown => 'Location not set yet';

  @override
  String get locationPermissionTitle => 'Location permission needed';

  @override
  String get locationPermissionBody =>
      'Tanbih uses your location to calculate prayer times where you are. Your location is never sent to any server.';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission was permanently denied. Open app settings to enable it, or pick a city manually.';

  @override
  String get locationChooseManually => 'Pick a city manually';

  @override
  String get notificationPermissionTitle => 'Notification permission needed';

  @override
  String get notificationPermissionBody =>
      'Without it, Tanbih cannot remind you when a prayer time begins.';

  @override
  String get exactAlarmPermissionTitle => 'Exact alarm permission';

  @override
  String get exactAlarmPermissionBody =>
      'Needed so the adhan sounds on time instead of being delayed by minutes.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrayerTimes => 'Prayer Times Settings';

  @override
  String get settingsPrayerTimesSubtitle =>
      'Settings for calculating prayer times';

  @override
  String get settingsLocation => 'Location Settings';

  @override
  String get settingsLocationSubtitle =>
      'Choose how your location is determined';

  @override
  String get settingsNotification => 'Notification Settings';

  @override
  String get settingsNotificationSubtitle => 'Notifications and reminders';

  @override
  String get settingsSilent => 'Silent Settings';

  @override
  String get settingsSilentSubtitle => 'Automatic silent mode during prayer';

  @override
  String get settingsHijri => 'Hijri Settings';

  @override
  String get settingsHijriSubtitle => 'Hijri date adjustment';

  @override
  String get settingsFajrAlarm => 'Fajr & Sahoor Alarm';

  @override
  String get settingsFajrAlarmSubtitle => 'Wake-up alarm for sahoor or Fajr';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsTheme => 'App Theme';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFollowSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuGeneral => 'General';

  @override
  String get menuOther => 'Other';

  @override
  String get menuQibla => 'Qibla Direction';

  @override
  String get menuDuas => 'Prayer Duas';

  @override
  String get menuWuduGuide => 'Wudu Guide';

  @override
  String get menuPrayerGuide => 'Prayer Guide';

  @override
  String get menuTasbih => 'Tasbih Counter';

  @override
  String get menuCalendar => 'Islamic Calendar';

  @override
  String get menuComingSoon => 'Soon';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonOpenSettings => 'Open Settings';

  @override
  String get commonAllow => 'Allow';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonToday => 'Today';

  @override
  String get errorNoInternet => 'No internet connection';

  @override
  String get errorNoInternetBody =>
      'Prayer times work fine offline. Some features such as city search need a connection.';

  @override
  String get errorCalculation => 'Could not calculate prayer times';

  @override
  String get errorUnexpected => 'Something went wrong';

  @override
  String get suhoorLabel => 'Suhoor';

  @override
  String get iftaarLabel => 'Iftar';

  @override
  String get allPrayersTitle => 'All Prayer Times';

  @override
  String get notificationOn => 'Notification on';

  @override
  String get notificationOff => 'Notification off';

  @override
  String get previousPrayer => 'Previous prayer';

  @override
  String get nextPrayerAction => 'Next prayer';

  @override
  String get openSettings => 'Open settings';

  @override
  String get openMenu => 'Open menu';

  @override
  String get menuFeedback => 'Feedback';

  @override
  String get menuFeedbackSubtitle => 'Share your thoughts with us';

  @override
  String get menuRateUs => 'Rate Us';

  @override
  String get menuRateUsSubtitle => 'Your experience on the app';

  @override
  String get menuShareApp => 'Share App';

  @override
  String get menuShareAppSubtitle => 'Help your friends become better Muslims';

  @override
  String get menuFinancialSupport => 'Financial Support';

  @override
  String get menuFinancialSupportSubtitle =>
      'Anyone can support and become part of sadaqah jariyah';

  @override
  String get settingsCalculations => 'Calculations';

  @override
  String get settingsTimes => 'Times';

  @override
  String get settingsMethods => 'Calculation Method';

  @override
  String get settingsJuristicMethod => 'Juristic Method (Asr)';

  @override
  String get settingsHigherLatitude => 'Higher Latitude Adjustment';

  @override
  String get settingsRamadanIsha => 'Adjust Isha in Ramadan';

  @override
  String get settingsRamadanIshaSubtitle =>
      'Add 30 minutes to Isha during Ramadan on the Umm Al-Qura method';

  @override
  String get settingsDst => 'Daylight Saving Adjustment';

  @override
  String get settingsDstSubtitle => 'Shift by 1 hour for summer time (DST)';

  @override
  String get settingsJumuah => 'Jumu\'ah Prayer Time';

  @override
  String get settingsJumuahSubtitle =>
      'Set the time your mosque starts Jumu\'ah';

  @override
  String get settingsManualAdjustments => 'Manual Time Adjustments';

  @override
  String get settingsManualAdjustmentsSubtitle => 'Shift prayer times by hand';

  @override
  String get settingsImsakOffset => 'Imsak Offset';

  @override
  String get settingsImsakOffsetSubtitle => 'How many minutes before Fajr';

  @override
  String get madhabShafi => 'Shafi\'i';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get highLatMiddle => 'Middle of the Night';

  @override
  String get highLatSeventh => 'One Seventh of the Night';

  @override
  String get highLatTwilight => 'Twilight Angle';

  @override
  String get methodKemenag => 'Kemenag RI';

  @override
  String get methodKemenagSubtitle => 'Recommended for Indonesia';

  @override
  String get methodMwl => 'Muslim World League';

  @override
  String get methodEgyptian => 'Egyptian General Authority of Survey';

  @override
  String get methodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get methodUmmAlQura => 'Umm Al-Qura University, Makkah';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodMoonsighting => 'Moonsighting Committee';

  @override
  String get methodIsna => 'ISNA (North America)';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodSingapore => 'Singapore';

  @override
  String get methodTurkey => 'Turkey';

  @override
  String get methodTehran => 'Tehran';

  @override
  String get valueNotSet => 'Not set';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get hijriOffsetTitle => 'Hijri Date Adjustment';

  @override
  String get hijriOffsetSubtitle => 'Shift the Hijri date forward or back';

  @override
  String dayOffsetValue(int days) {
    return '$days days';
  }

  @override
  String get settingsResetAdjustments => 'Reset to zero';

  @override
  String preReminderBody(int minutes, String prayer) {
    return '$minutes minutes until $prayer';
  }

  @override
  String get notificationActivate => 'Activate Notifications';

  @override
  String get notificationActivateSubtitle =>
      'Remind me when a prayer time starts';

  @override
  String get notificationPerPrayer => 'Per-Prayer Notifications';

  @override
  String get notificationSound => 'Notification Sound';

  @override
  String get notificationTest => 'Test Notification';

  @override
  String get notificationTestSubtitle => 'Send a sample notification now';

  @override
  String get preReminderTitle => 'Early Reminder';

  @override
  String get preReminderOff => 'Off';

  @override
  String get soundSilent => 'Silent';

  @override
  String get soundDefault => 'Default tone';

  @override
  String get soundAdhanShort => 'Short adhan';

  @override
  String get fajrAlarmMinutesTitle => 'How long before Fajr';

  @override
  String get permissionGrant => 'Allow';

  @override
  String get permissionFix => 'Fix';

  @override
  String get locationFailedTitle => 'Could not get your location';

  @override
  String get locationRetry => 'Try again';
}
