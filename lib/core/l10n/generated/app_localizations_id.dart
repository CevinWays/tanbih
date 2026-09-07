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
}
