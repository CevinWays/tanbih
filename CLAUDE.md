# Project: Tanbih

Flutter 3.41+ / Dart 3.11+ aplikasi pengingat shalat & adzan. **Android-first** (iOS menyusul).
Bloc state management, clean architecture per feature, get_it + injectable DI, auto_route navigation, Dio HTTP client.

**Offline-first adalah invariant:** jadwal shalat, penjadwalan notifikasi, pemutaran adzan, dan auto-silent berjalan
100% di device tanpa jaringan. Dio hanya untuk enhancement (download suara muadzin, pencarian kota online, remote
config). Setiap remote datasource wajib punya fallback lokal.

## Commands

- `flutter run -d <device-id>` — jalan di device fisik (**tidak pakai emulator**)
- `adb devices` — cek device tersambung sebelum run
- `flutter test` — semua test
- `flutter test test/features/prayer_times/domain/get_today_prayer_times_test.dart` — satu file
- `flutter analyze` — wajib nol issue
- `dart format .` — format semua file Dart
- `flutter pub get` — install dependency
- `dart run build_runner build --delete-conflicting-outputs` — codegen (freezed, injectable, auto_route)
- `flutter gen-l10n` — regenerate lokalisasi dari ARB
- `flutter build apk --debug` — bukti toolchain Android jalan
- `flutter run --profile -d <device-id>` — profil performa (wajib untuk layar glassmorphism)
- `flutter build appbundle --release` — build rilis Play Store

Jalankan `dart format . && flutter analyze && flutter test` sebelum commit.

### Catatan toolchain Android

SDK pakai **Android CLI baru** (`~/Library/Android/sdk/cmdline-tools/latest/bin/android`), bukan `sdkmanager` yang deprecated.
Warning `Android license status unknown` dari `flutter doctor` **diabaikan** — pemeriksaan legacy, tidak memblokir build.
Bukti sesungguhnya = `flutter build apk --debug`.
Platform terpasang hanya `android-37.0` → `compileSdk = 37`, `targetSdk = 37`, `minSdk = 24`. Jangan diturunkan.
Uji alarm & adzan pada build **release** juga, bukan cuma debug — R8 bisa mengobfuscate receiver/service.

**JDK: harus 21, bukan JBR Android Studio.** JBR yang dibundel Android Studio di mesin ini adalah JDK 25, sedangkan
AGP 8.11.1 + Gradle 8.14 hanya mendukung Java 17–24. Flutter sudah diarahkan ke Homebrew `openjdk@21`:

```bash
flutter config --jdk-dir=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
```

Kalau Gradle mengeluh soal versi Java, cek `flutter config` dulu — jangan naikkan Gradle ke 9.x, karena AGP 8.11.1
belum mendukungnya.

## Architecture

Clean architecture, feature-first, tiga lapis per feature. Dependensi satu arah:
**presentation → domain ← data**. Domain tidak boleh tahu Flutter, package pihak ketiga, atau platform channel.

- `lib/`
  - `main.dart` → `bootstrap()`
  - `bootstrap.dart` — init timezone, DI, notification channel, talker, error handler
  - `app.dart` — `MaterialApp.router`, tema, `localizationsDelegates`, BlocProvider global
  - `core/`
    - `config/` — `app_config.dart`, `calculation_presets.dart`
    - `di/` — `injector.dart`, `register_module.dart` (+ generated `injector.config.dart`)
    - `error/` — `failures.dart`, `exceptions.dart`, `dio_failure_mapper.dart`
    - `network/` — `api_client.dart`, `network_info.dart`, `interceptors/`
    - `usecases/` — `usecase.dart` (`UseCase<Type, Params>`, `NoParams`)
    - `routes/` — `app_router.dart`, `route_name.dart` (+ generated `app_router.gr.dart`)
    - `styles/` — `app_colors.dart`, `app_gradients.dart`, `app_text_style.dart`, `app_spacing.dart`, `app_theme.dart`, `prayer_theme.dart`, barrel `styles.dart`
    - `l10n/` — `app_id.arb`, `app_en.arb`
    - `services/` — pembungkus platform: `clock.dart`, `notification_service.dart`, `adhan_alarm_channel.dart`, `silent_mode_channel.dart`, `prayer_schedule_coordinator.dart`
    - `widgets/` — widget bersama: `glass_card.dart`, `setting_tile.dart`, dll
    - `utils/` — fungsi murni
  - `features/<feature>/`
    - `domain/` — `entities/`, `repositories/` (abstract), `usecases/`
    - `data/` — `datasources/` (abstract + `_impl`), `models/`, `repositories/` (impl)
    - `presentation/` — `bloc/`, `screens/`, `widgets/`
  - Feature: `prayer_times`, `location`, `notification`, `adhan_audio`, `silent_mode`, `qibla`, `settings`, `onboarding`, `menu`
- `android/app/src/main/kotlin/com/cevin/tanbih/` — alarm, audio adzan, silent mode (Kotlin)
- `test/` — mirror struktur `lib/`
- `assets/` — `audio/`, `icons/`, `fonts/` (Outfit + Poppins), `data/cities_id.json`

## Widget Conventions

- Default `StatelessWidget`. `StatefulWidget` hanya untuk animasi/controller lokal
- Baca state pakai `BlocBuilder` / `BlocSelector` / `context.watch`; kirim event `context.read<X>().add(...)`
- Pecah widget ke file sendiri kalau lewat ~80 baris. Satu widget publik per file
- Nama file: `home_screen.dart`, `prayer_row_tile.dart`, `glass_card.dart`
- `BlocSelector` kalau widget hanya butuh sebagian state — hindari rebuild subtree besar

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
        builder: (context, state) => switch (state.status) {
          PrayerTimesStatus.loading => const Center(child: CircularProgressIndicator()),
          PrayerTimesStatus.failure => ErrorView(failure: state.failure!),
          PrayerTimesStatus.success => _PrayerTimesView(times: state.times!),
          PrayerTimesStatus.initial => const SizedBox.shrink(),
        },
      ),
    );
  }
}
```

## State Management (Bloc)

- Satu bloc per file-set: `<name>_bloc.dart` / `<name>_event.dart` / `<name>_state.dart`
- `Bloc` untuk alur banyak event; `Cubit` untuk state sederhana (`LocaleCubit`, `ThemeCubit`, `NextPrayerCountdownCubit`)
- Event & state `Equatable` (atau freezed). **State = satu class + enum `status` + `copyWith`**, bukan class per-kondisi
- Bloc **hanya** memanggil usecase. Dilarang menyentuh datasource, `SharedPreferences`, plugin, atau platform channel
- Bloc tidak melempar exception ke UI — hasil usecase `Either<Failure, T>` dan di-`fold`

```dart
@injectable
class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  PrayerTimesBloc(this._getTodayPrayerTimes) : super(const PrayerTimesState()) {
    on<PrayerTimesLoadRequested>(_onLoadRequested);
  }

  final GetTodayPrayerTimes _getTodayPrayerTimes;

  Future<void> _onLoadRequested(
    PrayerTimesLoadRequested event,
    Emitter<PrayerTimesState> emit,
  ) async {
    emit(state.copyWith(status: PrayerTimesStatus.loading));
    final result = await _getTodayPrayerTimes(
      PrayerTimesParams(location: event.location),
    );
    emit(result.fold(
      (failure) => state.copyWith(status: PrayerTimesStatus.failure, failure: failure),
      (times) => state.copyWith(status: PrayerTimesStatus.success, times: times),
    ));
  }
}
```

## Use Cases & Error Handling

- Satu usecase satu class, `call(Params)` → `Future<Either<Failure, T>>`
- Tanpa argumen pakai `NoParams`
- Repository impl adalah **satu-satunya** tempat exception jadi `Failure`. Domain tidak pernah melihat exception

```dart
@injectable
class GetTodayPrayerTimes implements UseCase<DailyPrayerTimes, PrayerTimesParams> {
  const GetTodayPrayerTimes(this._repository, this._clock);

  final PrayerTimesRepository _repository;
  final Clock _clock;

  @override
  Future<Either<Failure, DailyPrayerTimes>> call(PrayerTimesParams params) =>
      _repository.getDailyTimes(
        coordinates: params.location.coordinates,
        date: _clock.now(),
        settings: params.settings,
      );
}
```

## Data Classes

- Entity & state pakai **freezed**; jalankan build_runner setelah mengubahnya
- Entity di `domain/entities/` bebas anotasi JSON. Model di `data/models/` mengurus serialisasi + punya `toEntity()`
- Domain **dilarang** mengimpor model dari layer data

## Dependency Injection (get_it + injectable)

- `@injectable` (baru tiap resolve), `@lazySingleton` (service global), `@Singleton(as: AbstractType)` untuk impl repository/datasource
- Package pihak ketiga (`SharedPreferences`, `Dio`, `FlutterLocalNotificationsPlugin`, `AudioPlayer`) didaftarkan di `core/di/register_module.dart` dengan `@module`
- `sl<T>()` **hanya** di `bootstrap.dart` dan `BlocProvider` — jangan service-locate di widget atau bloc, injeksi lewat constructor

## Waktu & Clock

Ini aplikasi berbasis waktu — waktu **wajib** bisa diinjeksi.

- Dilarang `DateTime.now()` di domain, data, atau bloc. Injeksi `Clock` dan pakai `_clock.now()`
- Penjadwalan notifikasi pakai `tz.TZDateTime`, bukan `DateTime` lokal
- Test memakai `FakeClock` untuk mengunci waktu

## Navigation (auto_route)

- Semua rute di `core/routes/app_router.dart`, path sebagai konstanta di `route_name.dart` — dilarang string ajaib
- Screen diberi `@RoutePage()`; setelah menambah screen jalankan build_runner
- Guard onboarding/izin di konfigurasi router, bukan di dalam widget

## Localization

- Dua bahasa: `id` (default) dan `en`. Semua string lewat ARB — `context.l10n.prayerFajr`
- Nama waktu shalat beda per bahasa: `Subuh/Dzuhur/Ashar/Maghrib/Isya` (id) vs `Fajr/Dhuhr/Asr/Maghrib/Isha` (en)
- Format tanggal & jam pakai `intl` dengan locale aktif — jangan susun string manual
- Tambah key baru ke **kedua** ARB sekaligus, lalu `flutter gen-l10n`

## Styling

- Warna, ukuran font, spacing hanya dari `core/styles/` — tidak ada literal di widget
- Gradient brand: `AppGradients.primary` = `#2DB1B3 → #7AC793`. **Outfit** untuk wordmark & heading, **Poppins** untuk body
- Tema per waktu shalat lewat `PrayerTheme` (`PrayerSlot → gradient + ilustrasi`)
- Glassmorphism: `BackdropFilter` mahal — maks ~3 instance per layar, ukur `flutter run --profile` di device fisik
- Ikon dari SVG export Figma di `assets/icons/` (via `flutter_svg`). Jangan menulis path SVG manual
- Desain sumber adalah file community — audit copy sisa app lain sebelum implement

## Networking (Dio)

- Client tunggal di `core/network/api_client.dart`, `@lazySingleton` lewat `register_module.dart`
- Chain: `HeaderInterceptor` → `ErrorInterceptor` → `RetryInterceptor` → `TalkerDioLogger` (debug-only)
- `DioException` **wajib** jadi `Failure` di `ErrorInterceptor`/`dio_failure_mapper.dart`. `DioException` tidak boleh keluar dari layer data
- Retry hanya 5xx / timeout / connection error, maks 2×, exponential backoff. **Jangan retry 4xx**
- Cek `NetworkInfo.isConnected` sebelum request — gagal cepat `NetworkFailure` daripada menunggu timeout
- Semua HTTP lewat remote datasource → repository. Widget, bloc, usecase **tidak pernah** menyentuh `Dio`
- Response dipetakan ke model bertipe. Jangan mengoper `Map<String, dynamic>` keluar dari datasource
- **Setiap remote datasource wajib punya pasangan lokal.** Pola: remote → kalau `NetworkFailure`/timeout, jatuh ke local
- Fitur inti (jadwal, notifikasi, adzan, auto-silent) **dilarang** menyentuh `core/network/`

## Notifikasi, Alarm, Silent Mode

- Penjadwalan **hanya** lewat `PrayerScheduleCoordinator`. Bloc/widget dilarang memanggil `zonedSchedule` atau platform channel langsung
- Notification id deterministik: `(daysSinceEpoch % 1000) * 20 + slotIndex` (+10 pre-reminder). Jangan id acak — harus bisa dibatalkan presisi
- Sound notification channel Android **immutable**. Ganti suara = channel id baru (`adhan_makkah_v2`), jangan edit channel lama
- Reschedule seluruh window 7 hari secara idempoten (`cancelAll` lalu jadwalkan ulang) — jangan patch sebagian
- Adzan penuh background = Kotlin native (AlarmManager → Receiver → ForegroundService → MediaPlayer). Dart hanya memanggil `AdhanAlarmChannel`
- Kalau mode adzan penuh aktif, notifikasi visual **wajib** channel silent — cegah suara dobel
- Auto-silent butuh **dua alarm** (masuk senyap + pulihkan) dan state disimpan di SharedPreferences **native** — app bisa dibunuh di antaranya
- Izin DND lewat `Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS` + `isNotificationPolicyAccessGranted()`, **bukan** `permission_handler`
- Auto-silent tidak boleh membungkam adzan: default mulai senyap setelah adzan selesai

## Testing

- Unit test usecase + repository dengan `mocktail` (bukan mockito)
- `bloc_test` untuk semua bloc/cubit
- **Golden test perhitungan waktu shalat wajib** — bandingkan jadwal resmi Kemenag, toleransi ±1 menit. Ini jantung aplikasi; jangan merge perubahan `AdhanCalculatorDataSource` tanpa test ini hijau
- Setiap opsi settings perhitungan punya test sendiri (madhab, Ramadan-Isha, DST, Jumuah, manual adjustment, hijri offset)
- Test repository wajib mencakup jalur fallback: remote gagal → local terpakai
- Widget test Home & Settings; golden test light/dark untuk komponen kritis
- Nama file test mirror file sumber + `_test.dart`

## Git

- Conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`
- Jalankan codegen sebelum commit kalau file freezed/injectable/auto_route berubah, dan commit hasil generate-nya
- `flutter analyze` wajib nol issue

## Do NOT

- Jangan memanggil package `adhan` di luar `AdhanCalculatorDataSource`
- Jangan pakai `DateTime.now()` di domain/data/bloc — injeksi `Clock`
- Jangan menjadwalkan notifikasi/alarm atau memanggil platform channel dari widget/bloc — lewat `PrayerScheduleCoordinator`
- Jangan mengubah sound channel notifikasi yang sudah dibuat — buat channel id baru
- Jangan menyimpan state silent mode hanya di memori Dart — harus di SharedPreferences native
- Jangan memanggil `Dio` dari widget, bloc, atau usecase — hanya remote datasource
- Jangan membiarkan `DioException` keluar dari layer data
- Jangan membuat remote datasource tanpa fallback lokal
- Jangan membuat fitur inti (jadwal, notifikasi, adzan, auto-silent) bergantung pada jaringan
- Jangan retry request 4xx
- Jangan pakai `setState` untuk data yang seharusnya di bloc
- Jangan pakai `BuildContext` melewati async gap — cek `mounted` dulu
- Jangan hardcode string — pakai `context.l10n.*`
- Jangan hardcode warna/spacing/ukuran font — pakai `core/styles/`
- Jangan pakai `print()` — pakai talker
- Jangan edit file generate: `*.g.dart`, `*.freezed.dart`, `injector.config.dart`, `app_router.gr.dart`
- Jangan `Timer.periodic` di bloc yang menyimpan state besar — countdown per detik tinggal di `NextPrayerCountdownCubit`
- Jangan minta izin background location — tidak dibutuhkan
- Jangan commit `key.properties`, keystore, atau kredensial signing
- Jangan menurunkan `compileSdk`/`targetSdk` di bawah 37
- Jangan menambahkan aset audio adzan tanpa lisensi jelas + atribusi di `assets/audio/CREDITS.md`
- Jangan berasumsi ada emulator — testing selalu di device fisik
- Jangan mengimplement copy sisa app lain dari desain community (splash "Prayer Reminder", "Script of Holy Quran", contoh Umm Al-Qura sebagai default)
