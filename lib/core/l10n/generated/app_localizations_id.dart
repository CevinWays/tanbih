// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Tanbih';

  @override
  String get appTagline => 'Pengingat shalat & adzan';

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerFajr => 'Subuh';

  @override
  String get prayerSunrise => 'Terbit';

  @override
  String get prayerDhuhr => 'Dzuhur';

  @override
  String get prayerJumuah => 'Jumat';

  @override
  String get prayerAsr => 'Ashar';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isya';

  @override
  String get nextPrayerLabel => 'Waktu berikutnya';

  @override
  String get remainingLabel => 'Tersisa';

  @override
  String countdownHoursMinutes(int hours, int minutes) {
    return '$hours jam $minutes menit';
  }

  @override
  String countdownMinutes(int minutes) {
    return '$minutes menit';
  }

  @override
  String countdownSemantics(String prayer, String duration) {
    return '$prayer dalam $duration';
  }

  @override
  String get prayerTimeNow => 'Sudah masuk waktu';

  @override
  String get locationCurrent => 'Lokasi saat ini';

  @override
  String get locationTapToChange => 'Ketuk untuk ubah lokasi';

  @override
  String get locationUnknown => 'Lokasi belum diketahui';

  @override
  String get locationPermissionTitle => 'Izin lokasi diperlukan';

  @override
  String get locationPermissionBody =>
      'Tanbih memakai lokasi untuk menghitung waktu shalat di tempatmu. Lokasi tidak pernah dikirim ke server mana pun.';

  @override
  String get locationPermissionDeniedForever =>
      'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengaktifkannya, atau pilih kota secara manual.';

  @override
  String get locationChooseManually => 'Pilih kota manual';

  @override
  String get notificationPermissionTitle => 'Izin notifikasi diperlukan';

  @override
  String get notificationPermissionBody =>
      'Tanpa izin ini, Tanbih tidak bisa mengingatkanmu saat waktu shalat masuk.';

  @override
  String get exactAlarmPermissionTitle => 'Izin alarm presisi';

  @override
  String get exactAlarmPermissionBody =>
      'Diperlukan agar adzan berbunyi tepat waktu, bukan tertunda beberapa menit.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsPrayerTimes => 'Pengaturan Waktu Shalat';

  @override
  String get settingsPrayerTimesSubtitle => 'Metode perhitungan waktu shalat';

  @override
  String get settingsLocation => 'Pengaturan Lokasi';

  @override
  String get settingsLocationSubtitle => 'Atur bagaimana lokasi ditentukan';

  @override
  String get settingsNotification => 'Pengaturan Notifikasi';

  @override
  String get settingsNotificationSubtitle => 'Notifikasi dan pengingat';

  @override
  String get settingsSilent => 'Pengaturan Senyap';

  @override
  String get settingsSilentSubtitle => 'Mode senyap otomatis saat shalat';

  @override
  String get settingsHijri => 'Pengaturan Hijriah';

  @override
  String get settingsHijriSubtitle => 'Koreksi tanggal Hijriah';

  @override
  String get settingsFajrAlarm => 'Alarm Subuh & Sahur';

  @override
  String get settingsFajrAlarmSubtitle => 'Alarm bangun untuk sahur atau Subuh';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsDarkMode => 'Mode Gelap';

  @override
  String get settingsTheme => 'Tema Aplikasi';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFollowSystem => 'Ikuti sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Ikuti sistem';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuGeneral => 'Umum';

  @override
  String get menuOther => 'Lainnya';

  @override
  String get menuQibla => 'Arah Kiblat';

  @override
  String get menuDuas => 'Doa Shalat';

  @override
  String get menuWuduGuide => 'Panduan Wudhu';

  @override
  String get menuPrayerGuide => 'Panduan Shalat';

  @override
  String get menuTasbih => 'Tasbih Digital';

  @override
  String get menuCalendar => 'Kalender Islam';

  @override
  String get menuComingSoon => 'Segera';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonOpenSettings => 'Buka Pengaturan';

  @override
  String get commonAllow => 'Izinkan';

  @override
  String get commonNotNow => 'Nanti saja';

  @override
  String get commonSearch => 'Cari';

  @override
  String get commonToday => 'Hari ini';

  @override
  String get errorNoInternet => 'Tidak ada koneksi internet';

  @override
  String get errorNoInternetBody =>
      'Jadwal shalat tetap bisa dipakai tanpa internet. Sebagian fitur seperti pencarian kota memerlukan koneksi.';

  @override
  String get errorCalculation => 'Gagal menghitung waktu shalat';

  @override
  String get errorUnexpected => 'Terjadi kesalahan tak terduga';

  @override
  String get suhoorLabel => 'Imsak';

  @override
  String get iftaarLabel => 'Berbuka';

  @override
  String get allPrayersTitle => 'Semua Waktu Shalat';

  @override
  String get scheduleCurrentPrayer => 'Waktu shalat saat ini';

  @override
  String get openSettings => 'Buka pengaturan';

  @override
  String get openMenu => 'Buka menu';

  @override
  String get menuFeedback => 'Masukan';

  @override
  String get menuFeedbackSubtitle => 'Sampaikan pendapatmu ke kami';

  @override
  String get menuRateUs => 'Beri Rating';

  @override
  String get menuRateUsSubtitle => 'Pengalamanmu memakai aplikasi';

  @override
  String get menuShareApp => 'Bagikan Aplikasi';

  @override
  String get menuShareAppSubtitle =>
      'Bantu temanmu jadi muslim yang lebih baik';

  @override
  String get menuFinancialSupport => 'Dukungan Dana';

  @override
  String get menuFinancialSupportSubtitle =>
      'Siapa pun bisa mendukung dan jadi bagian dari sadaqah jariyah';

  @override
  String get settingsCalculations => 'Perhitungan';

  @override
  String get settingsTimes => 'Waktu';

  @override
  String get settingsMethods => 'Metode Perhitungan';

  @override
  String get settingsJuristicMethod => 'Mazhab (Ashar)';

  @override
  String get settingsHigherLatitude => 'Penyesuaian Lintang Tinggi';

  @override
  String get settingsRamadanIsha => 'Sesuaikan Isya saat Ramadan';

  @override
  String get settingsRamadanIshaSubtitle =>
      'Tambah 30 menit ke waktu Isya selama Ramadan pada metode Umm Al-Qura';

  @override
  String get settingsDst => 'Penyesuaian Daylight Saving';

  @override
  String get settingsDstSubtitle => 'Geser 1 jam untuk waktu musim panas (DST)';

  @override
  String get settingsJumuah => 'Waktu Shalat Jumat';

  @override
  String get settingsJumuahSubtitle => 'Isi waktu Jumat sesuai masjidmu';

  @override
  String get settingsManualAdjustments => 'Koreksi Waktu Manual';

  @override
  String get settingsManualAdjustmentsSubtitle =>
      'Geser waktu shalat secara manual';

  @override
  String get settingsImsakOffset => 'Selisih Imsak';

  @override
  String get settingsImsakOffsetSubtitle => 'Berapa menit sebelum Subuh';

  @override
  String get madhabShafi => 'Syafi\'i';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get highLatMiddle => 'Tengah Malam';

  @override
  String get highLatSeventh => 'Sepertujuh Malam';

  @override
  String get highLatTwilight => 'Sudut Senja';

  @override
  String get methodKemenag => 'Kemenag RI';

  @override
  String get methodKemenagSubtitle => 'Disarankan untuk Indonesia';

  @override
  String get methodMwl => 'Muslim World League';

  @override
  String get methodEgyptian => 'Otoritas Survei Mesir';

  @override
  String get methodKarachi => 'Universitas Ilmu Islam, Karachi';

  @override
  String get methodUmmAlQura => 'Universitas Umm Al-Qura, Makkah';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodMoonsighting => 'Moonsighting Committee';

  @override
  String get methodIsna => 'ISNA (Amerika Utara)';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodSingapore => 'Singapura';

  @override
  String get methodTurkey => 'Turki';

  @override
  String get methodTehran => 'Tehran';

  @override
  String get valueNotSet => 'Belum diatur';

  @override
  String minutesShort(int minutes) {
    return '$minutes mnt';
  }

  @override
  String get hijriOffsetTitle => 'Koreksi Tanggal Hijriah';

  @override
  String get hijriOffsetSubtitle => 'Geser tanggal Hijriah maju atau mundur';

  @override
  String dayOffsetValue(int days) {
    return '$days hari';
  }

  @override
  String get settingsResetAdjustments => 'Kembalikan ke nol';

  @override
  String preReminderBody(int minutes, String prayer) {
    return '$minutes menit lagi menuju $prayer';
  }

  @override
  String get notificationActivate => 'Aktifkan Notifikasi';

  @override
  String get notificationActivateSubtitle => 'Ingatkan saat waktu shalat masuk';

  @override
  String get notificationPerPrayer => 'Notifikasi Tiap Waktu';

  @override
  String get notificationSound => 'Suara Notifikasi';

  @override
  String get notificationTest => 'Tes Notifikasi';

  @override
  String get notificationTestSubtitle => 'Kirim contoh notifikasi sekarang';

  @override
  String get preReminderTitle => 'Pengingat Awal';

  @override
  String get preReminderOff => 'Mati';

  @override
  String get soundSilent => 'Tanpa suara';

  @override
  String get soundDefault => 'Nada bawaan';

  @override
  String get soundAdhanShort => 'Adzan singkat';

  @override
  String get fajrAlarmMinutesTitle => 'Berapa lama sebelum Subuh';

  @override
  String get permissionGrant => 'Izinkan';

  @override
  String get permissionFix => 'Perbaiki';

  @override
  String get locationFailedTitle => 'Lokasi belum bisa didapat';

  @override
  String get locationRetry => 'Coba lagi';

  @override
  String get permissionIntroTitle => 'Izinkan notifikasi';

  @override
  String get permissionIntroBody =>
      'Tanbih perlu izin notifikasi untuk mengingatkanmu saat waktu shalat masuk. Tanpa ini, adzan dan pengingat tidak akan muncul sama sekali.';

  @override
  String get themeTitle => 'Tema Aplikasi';

  @override
  String get fullAdhanTitle => 'Adzan Penuh';

  @override
  String get fullAdhanSubtitle =>
      'Putar adzan lengkap saat waktu shalat masuk, walau aplikasi tertutup';

  @override
  String get fullAdhanPreview => 'Coba Adzan';

  @override
  String get fullAdhanPreviewSubtitle => 'Putar adzan sekarang';

  @override
  String get fullAdhanStop => 'Hentikan';

  @override
  String get qiblaTitle => 'Arah Kiblat';

  @override
  String get qiblaFacing => 'Kamu menghadap Makkah';

  @override
  String get qiblaTurn => 'Putar HP sampai penanda lurus ke atas';

  @override
  String qiblaBearing(int degrees) {
    return '$degrees° dari utara';
  }

  @override
  String get qiblaNoSensor => 'HP ini tidak punya sensor kompas';

  @override
  String qiblaNoSensorBody(int degrees) {
    return 'Arah kiblat tetap bisa dipakai: hadapkan $degrees° dari utara, diukur searah jarum jam.';
  }

  @override
  String get qiblaCalibrate =>
      'Gerakkan HP membentuk angka 8 untuk mengkalibrasi kompas';

  @override
  String get aboutTitle => 'Tentang';

  @override
  String aboutVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get aboutTagline => 'Pengingat shalat & adzan';

  @override
  String get aboutCreditsTitle => 'Kredit & Lisensi';

  @override
  String get aboutAdhanTitle => 'Rekaman adzan';

  @override
  String get aboutAdhanBody =>
      '\"Beautiful adhan\" oleh Adam-synagda, Wikimedia Commons. Didedikasikan ke domain publik (CC0 1.0).';

  @override
  String get aboutFontsTitle => 'Font';

  @override
  String get aboutFontsBody => 'Outfit dan Poppins, SIL Open Font License 1.1.';

  @override
  String get aboutCitiesTitle => 'Data kota';

  @override
  String get aboutCitiesBody =>
      'Koordinat kota berasal dari OpenStreetMap © kontributor OpenStreetMap, tersedia di bawah Open Database License (ODbL).';

  @override
  String get aboutCalcTitle => 'Perhitungan waktu shalat';

  @override
  String get aboutCalcBody =>
      'Dihitung di perangkat memakai pustaka Adhan. Default mengikuti metode Kemenag RI.';

  @override
  String get aboutPrivacyTitle => 'Privasi';

  @override
  String get aboutPrivacyBody =>
      'Lokasi hanya dipakai di perangkat ini untuk menghitung waktu shalat. Lokasi tidak pernah dikirim ke server mana pun.';
}
