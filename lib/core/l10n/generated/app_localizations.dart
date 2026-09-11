import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Tanbih'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In id, this message translates to:
  /// **'Pengingat shalat & adzan'**
  String get appTagline;

  /// No description provided for @prayerImsak.
  ///
  /// In id, this message translates to:
  /// **'Imsak'**
  String get prayerImsak;

  /// No description provided for @prayerFajr.
  ///
  /// In id, this message translates to:
  /// **'Subuh'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In id, this message translates to:
  /// **'Terbit'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In id, this message translates to:
  /// **'Dzuhur'**
  String get prayerDhuhr;

  /// No description provided for @prayerJumuah.
  ///
  /// In id, this message translates to:
  /// **'Jumat'**
  String get prayerJumuah;

  /// No description provided for @prayerAsr.
  ///
  /// In id, this message translates to:
  /// **'Ashar'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In id, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In id, this message translates to:
  /// **'Isya'**
  String get prayerIsha;

  /// No description provided for @nextPrayerLabel.
  ///
  /// In id, this message translates to:
  /// **'Waktu berikutnya'**
  String get nextPrayerLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In id, this message translates to:
  /// **'Tersisa'**
  String get remainingLabel;

  /// No description provided for @countdownHoursMinutes.
  ///
  /// In id, this message translates to:
  /// **'{hours} jam {minutes} menit'**
  String countdownHoursMinutes(int hours, int minutes);

  /// No description provided for @countdownMinutes.
  ///
  /// In id, this message translates to:
  /// **'{minutes} menit'**
  String countdownMinutes(int minutes);

  /// No description provided for @prayerTimeNow.
  ///
  /// In id, this message translates to:
  /// **'Sudah masuk waktu'**
  String get prayerTimeNow;

  /// No description provided for @locationCurrent.
  ///
  /// In id, this message translates to:
  /// **'Lokasi saat ini'**
  String get locationCurrent;

  /// No description provided for @locationTapToChange.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk ubah lokasi'**
  String get locationTapToChange;

  /// No description provided for @locationUnknown.
  ///
  /// In id, this message translates to:
  /// **'Lokasi belum diketahui'**
  String get locationUnknown;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi diperlukan'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionBody.
  ///
  /// In id, this message translates to:
  /// **'Tanbih memakai lokasi untuk menghitung waktu shalat di tempatmu. Lokasi tidak pernah dikirim ke server mana pun.'**
  String get locationPermissionBody;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengaktifkannya, atau pilih kota secara manual.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationChooseManually.
  ///
  /// In id, this message translates to:
  /// **'Pilih kota manual'**
  String get locationChooseManually;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi diperlukan'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionBody.
  ///
  /// In id, this message translates to:
  /// **'Tanpa izin ini, Tanbih tidak bisa mengingatkanmu saat waktu shalat masuk.'**
  String get notificationPermissionBody;

  /// No description provided for @exactAlarmPermissionTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin alarm presisi'**
  String get exactAlarmPermissionTitle;

  /// No description provided for @exactAlarmPermissionBody.
  ///
  /// In id, this message translates to:
  /// **'Diperlukan agar adzan berbunyi tepat waktu, bukan tertunda beberapa menit.'**
  String get exactAlarmPermissionBody;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsPrayerTimes.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Waktu Shalat'**
  String get settingsPrayerTimes;

  /// No description provided for @settingsPrayerTimesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Metode perhitungan waktu shalat'**
  String get settingsPrayerTimesSubtitle;

  /// No description provided for @settingsLocation.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Lokasi'**
  String get settingsLocation;

  /// No description provided for @settingsLocationSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Atur bagaimana lokasi ditentukan'**
  String get settingsLocationSubtitle;

  /// No description provided for @settingsNotification.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Notifikasi'**
  String get settingsNotification;

  /// No description provided for @settingsNotificationSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi dan pengingat'**
  String get settingsNotificationSubtitle;

  /// No description provided for @settingsSilent.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Senyap'**
  String get settingsSilent;

  /// No description provided for @settingsSilentSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Mode senyap otomatis saat shalat'**
  String get settingsSilentSubtitle;

  /// No description provided for @settingsHijri.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Hijriah'**
  String get settingsHijri;

  /// No description provided for @settingsHijriSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Koreksi tanggal Hijriah'**
  String get settingsHijriSubtitle;

  /// No description provided for @settingsFajrAlarm.
  ///
  /// In id, this message translates to:
  /// **'Alarm Subuh & Sahur'**
  String get settingsFajrAlarm;

  /// No description provided for @settingsFajrAlarmSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Alarm bangun untuk sahur atau Subuh'**
  String get settingsFajrAlarmSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsLanguage;

  /// No description provided for @settingsDarkMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get settingsDarkMode;

  /// No description provided for @settingsTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema Aplikasi'**
  String get settingsTheme;

  /// No description provided for @languageIndonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageEnglish.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFollowSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get languageFollowSystem;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get themeSystem;

  /// No description provided for @menuTitle.
  ///
  /// In id, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @menuGeneral.
  ///
  /// In id, this message translates to:
  /// **'Umum'**
  String get menuGeneral;

  /// No description provided for @menuOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get menuOther;

  /// No description provided for @menuQibla.
  ///
  /// In id, this message translates to:
  /// **'Arah Kiblat'**
  String get menuQibla;

  /// No description provided for @menuDuas.
  ///
  /// In id, this message translates to:
  /// **'Doa Shalat'**
  String get menuDuas;

  /// No description provided for @menuWuduGuide.
  ///
  /// In id, this message translates to:
  /// **'Panduan Wudhu'**
  String get menuWuduGuide;

  /// No description provided for @menuPrayerGuide.
  ///
  /// In id, this message translates to:
  /// **'Panduan Shalat'**
  String get menuPrayerGuide;

  /// No description provided for @menuTasbih.
  ///
  /// In id, this message translates to:
  /// **'Tasbih Digital'**
  String get menuTasbih;

  /// No description provided for @menuCalendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender Islam'**
  String get menuCalendar;

  /// No description provided for @menuComingSoon.
  ///
  /// In id, this message translates to:
  /// **'Segera'**
  String get menuComingSoon;

  /// No description provided for @commonRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get commonClose;

  /// No description provided for @commonOpenSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan'**
  String get commonOpenSettings;

  /// No description provided for @commonAllow.
  ///
  /// In id, this message translates to:
  /// **'Izinkan'**
  String get commonAllow;

  /// No description provided for @commonNotNow.
  ///
  /// In id, this message translates to:
  /// **'Nanti saja'**
  String get commonNotNow;

  /// No description provided for @commonSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get commonSearch;

  /// No description provided for @commonToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get commonToday;

  /// No description provided for @errorNoInternet.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi internet'**
  String get errorNoInternet;

  /// No description provided for @errorNoInternetBody.
  ///
  /// In id, this message translates to:
  /// **'Jadwal shalat tetap bisa dipakai tanpa internet. Sebagian fitur seperti pencarian kota memerlukan koneksi.'**
  String get errorNoInternetBody;

  /// No description provided for @errorCalculation.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghitung waktu shalat'**
  String get errorCalculation;

  /// No description provided for @errorUnexpected.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan tak terduga'**
  String get errorUnexpected;

  /// No description provided for @suhoorLabel.
  ///
  /// In id, this message translates to:
  /// **'Imsak'**
  String get suhoorLabel;

  /// No description provided for @iftaarLabel.
  ///
  /// In id, this message translates to:
  /// **'Berbuka'**
  String get iftaarLabel;

  /// No description provided for @allPrayersTitle.
  ///
  /// In id, this message translates to:
  /// **'Semua Waktu Shalat'**
  String get allPrayersTitle;

  /// No description provided for @notificationOn.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi aktif'**
  String get notificationOn;

  /// No description provided for @notificationOff.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi mati'**
  String get notificationOff;

  /// No description provided for @previousPrayer.
  ///
  /// In id, this message translates to:
  /// **'Waktu sebelumnya'**
  String get previousPrayer;

  /// No description provided for @nextPrayerAction.
  ///
  /// In id, this message translates to:
  /// **'Waktu berikutnya'**
  String get nextPrayerAction;

  /// No description provided for @openSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan'**
  String get openSettings;

  /// No description provided for @openMenu.
  ///
  /// In id, this message translates to:
  /// **'Buka menu'**
  String get openMenu;

  /// No description provided for @menuFeedback.
  ///
  /// In id, this message translates to:
  /// **'Masukan'**
  String get menuFeedback;

  /// No description provided for @menuFeedbackSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Sampaikan pendapatmu ke kami'**
  String get menuFeedbackSubtitle;

  /// No description provided for @menuRateUs.
  ///
  /// In id, this message translates to:
  /// **'Beri Rating'**
  String get menuRateUs;

  /// No description provided for @menuRateUsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pengalamanmu memakai aplikasi'**
  String get menuRateUsSubtitle;

  /// No description provided for @menuShareApp.
  ///
  /// In id, this message translates to:
  /// **'Bagikan Aplikasi'**
  String get menuShareApp;

  /// No description provided for @menuShareAppSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bantu temanmu jadi muslim yang lebih baik'**
  String get menuShareAppSubtitle;

  /// No description provided for @menuFinancialSupport.
  ///
  /// In id, this message translates to:
  /// **'Dukungan Dana'**
  String get menuFinancialSupport;

  /// No description provided for @menuFinancialSupportSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Siapa pun bisa mendukung dan jadi bagian dari sadaqah jariyah'**
  String get menuFinancialSupportSubtitle;

  /// No description provided for @settingsCalculations.
  ///
  /// In id, this message translates to:
  /// **'Perhitungan'**
  String get settingsCalculations;

  /// No description provided for @settingsTimes.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get settingsTimes;

  /// No description provided for @settingsMethods.
  ///
  /// In id, this message translates to:
  /// **'Metode Perhitungan'**
  String get settingsMethods;

  /// No description provided for @settingsJuristicMethod.
  ///
  /// In id, this message translates to:
  /// **'Mazhab (Ashar)'**
  String get settingsJuristicMethod;

  /// No description provided for @settingsHigherLatitude.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian Lintang Tinggi'**
  String get settingsHigherLatitude;

  /// No description provided for @settingsRamadanIsha.
  ///
  /// In id, this message translates to:
  /// **'Sesuaikan Isya saat Ramadan'**
  String get settingsRamadanIsha;

  /// No description provided for @settingsRamadanIshaSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah 30 menit ke waktu Isya selama Ramadan pada metode Umm Al-Qura'**
  String get settingsRamadanIshaSubtitle;

  /// No description provided for @settingsDst.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian Daylight Saving'**
  String get settingsDst;

  /// No description provided for @settingsDstSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Geser 1 jam untuk waktu musim panas (DST)'**
  String get settingsDstSubtitle;

  /// No description provided for @settingsJumuah.
  ///
  /// In id, this message translates to:
  /// **'Waktu Shalat Jumat'**
  String get settingsJumuah;

  /// No description provided for @settingsJumuahSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Isi waktu Jumat sesuai masjidmu'**
  String get settingsJumuahSubtitle;

  /// No description provided for @settingsManualAdjustments.
  ///
  /// In id, this message translates to:
  /// **'Koreksi Waktu Manual'**
  String get settingsManualAdjustments;

  /// No description provided for @settingsManualAdjustmentsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Geser waktu shalat secara manual'**
  String get settingsManualAdjustmentsSubtitle;

  /// No description provided for @settingsImsakOffset.
  ///
  /// In id, this message translates to:
  /// **'Selisih Imsak'**
  String get settingsImsakOffset;

  /// No description provided for @settingsImsakOffsetSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Berapa menit sebelum Subuh'**
  String get settingsImsakOffsetSubtitle;

  /// No description provided for @madhabShafi.
  ///
  /// In id, this message translates to:
  /// **'Syafi\'i'**
  String get madhabShafi;

  /// No description provided for @madhabHanafi.
  ///
  /// In id, this message translates to:
  /// **'Hanafi'**
  String get madhabHanafi;

  /// No description provided for @highLatMiddle.
  ///
  /// In id, this message translates to:
  /// **'Tengah Malam'**
  String get highLatMiddle;

  /// No description provided for @highLatSeventh.
  ///
  /// In id, this message translates to:
  /// **'Sepertujuh Malam'**
  String get highLatSeventh;

  /// No description provided for @highLatTwilight.
  ///
  /// In id, this message translates to:
  /// **'Sudut Senja'**
  String get highLatTwilight;

  /// No description provided for @methodKemenag.
  ///
  /// In id, this message translates to:
  /// **'Kemenag RI'**
  String get methodKemenag;

  /// No description provided for @methodKemenagSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Disarankan untuk Indonesia'**
  String get methodKemenagSubtitle;

  /// No description provided for @methodMwl.
  ///
  /// In id, this message translates to:
  /// **'Muslim World League'**
  String get methodMwl;

  /// No description provided for @methodEgyptian.
  ///
  /// In id, this message translates to:
  /// **'Otoritas Survei Mesir'**
  String get methodEgyptian;

  /// No description provided for @methodKarachi.
  ///
  /// In id, this message translates to:
  /// **'Universitas Ilmu Islam, Karachi'**
  String get methodKarachi;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In id, this message translates to:
  /// **'Universitas Umm Al-Qura, Makkah'**
  String get methodUmmAlQura;

  /// No description provided for @methodDubai.
  ///
  /// In id, this message translates to:
  /// **'Dubai'**
  String get methodDubai;

  /// No description provided for @methodMoonsighting.
  ///
  /// In id, this message translates to:
  /// **'Moonsighting Committee'**
  String get methodMoonsighting;

  /// No description provided for @methodIsna.
  ///
  /// In id, this message translates to:
  /// **'ISNA (Amerika Utara)'**
  String get methodIsna;

  /// No description provided for @methodKuwait.
  ///
  /// In id, this message translates to:
  /// **'Kuwait'**
  String get methodKuwait;

  /// No description provided for @methodQatar.
  ///
  /// In id, this message translates to:
  /// **'Qatar'**
  String get methodQatar;

  /// No description provided for @methodSingapore.
  ///
  /// In id, this message translates to:
  /// **'Singapura'**
  String get methodSingapore;

  /// No description provided for @methodTurkey.
  ///
  /// In id, this message translates to:
  /// **'Turki'**
  String get methodTurkey;

  /// No description provided for @methodTehran.
  ///
  /// In id, this message translates to:
  /// **'Tehran'**
  String get methodTehran;

  /// No description provided for @valueNotSet.
  ///
  /// In id, this message translates to:
  /// **'Belum diatur'**
  String get valueNotSet;

  /// No description provided for @minutesShort.
  ///
  /// In id, this message translates to:
  /// **'{minutes} mnt'**
  String minutesShort(int minutes);

  /// No description provided for @hijriOffsetTitle.
  ///
  /// In id, this message translates to:
  /// **'Koreksi Tanggal Hijriah'**
  String get hijriOffsetTitle;

  /// No description provided for @hijriOffsetSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Geser tanggal Hijriah maju atau mundur'**
  String get hijriOffsetSubtitle;

  /// No description provided for @dayOffsetValue.
  ///
  /// In id, this message translates to:
  /// **'{days} hari'**
  String dayOffsetValue(int days);

  /// No description provided for @settingsResetAdjustments.
  ///
  /// In id, this message translates to:
  /// **'Kembalikan ke nol'**
  String get settingsResetAdjustments;

  /// No description provided for @preReminderBody.
  ///
  /// In id, this message translates to:
  /// **'{minutes} menit lagi menuju {prayer}'**
  String preReminderBody(int minutes, String prayer);

  /// No description provided for @notificationActivate.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Notifikasi'**
  String get notificationActivate;

  /// No description provided for @notificationActivateSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ingatkan saat waktu shalat masuk'**
  String get notificationActivateSubtitle;

  /// No description provided for @notificationPerPrayer.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Tiap Waktu'**
  String get notificationPerPrayer;

  /// No description provided for @notificationSound.
  ///
  /// In id, this message translates to:
  /// **'Suara Notifikasi'**
  String get notificationSound;

  /// No description provided for @notificationTest.
  ///
  /// In id, this message translates to:
  /// **'Tes Notifikasi'**
  String get notificationTest;

  /// No description provided for @notificationTestSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kirim contoh notifikasi sekarang'**
  String get notificationTestSubtitle;

  /// No description provided for @preReminderTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Awal'**
  String get preReminderTitle;

  /// No description provided for @preReminderOff.
  ///
  /// In id, this message translates to:
  /// **'Mati'**
  String get preReminderOff;

  /// No description provided for @soundSilent.
  ///
  /// In id, this message translates to:
  /// **'Tanpa suara'**
  String get soundSilent;

  /// No description provided for @soundDefault.
  ///
  /// In id, this message translates to:
  /// **'Nada bawaan'**
  String get soundDefault;

  /// No description provided for @soundAdhanShort.
  ///
  /// In id, this message translates to:
  /// **'Adzan singkat'**
  String get soundAdhanShort;

  /// No description provided for @fajrAlarmMinutesTitle.
  ///
  /// In id, this message translates to:
  /// **'Berapa lama sebelum Subuh'**
  String get fajrAlarmMinutesTitle;

  /// No description provided for @permissionGrant.
  ///
  /// In id, this message translates to:
  /// **'Izinkan'**
  String get permissionGrant;

  /// No description provided for @permissionFix.
  ///
  /// In id, this message translates to:
  /// **'Perbaiki'**
  String get permissionFix;

  /// No description provided for @locationFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Lokasi belum bisa didapat'**
  String get locationFailedTitle;

  /// No description provided for @locationRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get locationRetry;

  /// No description provided for @permissionIntroTitle.
  ///
  /// In id, this message translates to:
  /// **'Izinkan notifikasi'**
  String get permissionIntroTitle;

  /// No description provided for @permissionIntroBody.
  ///
  /// In id, this message translates to:
  /// **'Tanbih perlu izin notifikasi untuk mengingatkanmu saat waktu shalat masuk. Tanpa ini, adzan dan pengingat tidak akan muncul sama sekali.'**
  String get permissionIntroBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
