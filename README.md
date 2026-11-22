# Tanbih — Project Facts

Aplikasi pengingat shalat & adzan. Android-first. Dokumen ini menyimpan keputusan dan
fakta lingkungan yang tidak terbaca dari kode. Untuk aturan ngoding, lihat `CLAUDE.md`.

## Identitas

| | |
|---|---|
| Nama | **Tanbih** — تَنْبِيه (peringatan/pengingat) |
| Application id | `com.cevin.tanbih` |
| Tagline | Smart Notification Hub · Alert & Signal |
| Play Store | Nama "Tanbih" bebas (dicek 2026-09-07 — hanya ada "Tanbihul Ghofilin", kitab, beda) |

## Keputusan terkunci

| Aspek | Keputusan |
|---|---|
| Metode hitung | **Kemenag RI** default (Fajr 20°, Isha 18°, ihtiyati +2 menit); picker 13 preset `adhan` tetap tersedia |
| Adzan | Android: adzan penuh di background (native FGS + MediaPlayer). iOS → backlog |
| Platform | Android-first; folder iOS tetap compile tapi belum difitur-lengkapi |
| Testing | **Device fisik saja**, tanpa emulator |
| Bahasa | ID (default) + EN |
| State management | Bloc/Cubit + `Either<Failure,T>` + enum `status` |
| Network | Dio + interceptor, **enhancement only** — fitur inti tetap offline |
| Palet | Hybrid: struktur & glassmorphism dari desain Figma, warna primer dari brand |
| Logo | v1 — mark lonceng bersih |

## Brand tokens

| Token | Nilai |
|---|---|
| Primary gradient (G1) | `#2DB1B3 → #7AC793` — Teal to Mint |
| Teks utama | `#373232` |
| Font wordmark & heading | Outfit Bold |
| Font body | Poppins |
| Efek | Glassmorphism — fill `rgba(255,255,255,0.25)`, border `rgba(255,255,255,0.1)`, blur 25px |

## Desain Figma

File: `8ac5YePHkkDtxkMmSjJ1vb` — *Complete Islamic Prayer App Design* (community file), page `0:1` ("app").
32 screen 360×800. Inventaris node id lengkap ada di plan.

Node penting:

| Node | Isi |
|---|---|
| `1:44` | Splash — **copy-nya milik app lain**, wajib di-rebrand |
| `1:66` / `2002:53285` | Home + varian tema per waktu shalat |
| `2002:55899` | Komponen carousel countdown lingkaran |
| `2002:63668` | Settings (hub) |
| `4003:1136` | tanbih-logo v1 ← **dipakai untuk launcher icon** |
| `4004:1173` | tanbih-logo v2 |
| `4004:1280` | Logo Exploration Board (3 konsep alternatif) |

⚠️ Ini file community — masih ada sisa copy app lain: splash "Prayer Reminder / Bringing you closer to Allah",
teks "Please select the Script of Holy Quran you want to read.", dan contoh metode "Umm Al-Qura" sebagai default.
Jangan diimplement mentah.

## Lingkungan build (mesin dev)

| | |
|---|---|
| Flutter | 3.41.6 stable · Dart 3.11.4 · `~/developer/flutter` |
| Android SDK | `~/Library/Android/sdk` — **Android CLI baru** v1.0.15985488 (cmdline-tools 23.0.0) |
| Platform | `android-37.0` (satu-satunya; `android-36` tidak ada) → `compileSdk = 37` |
| Build-tools | 36.0.0 · platform-tools 37.0.1 |
| JDK | **Homebrew `openjdk@21`** — JBR Android Studio adalah JDK 25, tidak kompatibel dengan Gradle 8.14 |
| AGP / Gradle / Kotlin | 8.11.1 / 8.14 / 2.2.20 |
| Xcode | 26.4.1 (iOS belum jadi fokus) |

- `flutter doctor` menampilkan `✗ Android license status unknown` — **false alarm**, itu pemeriksaan legacy
  `sdkmanager`. Tidak memblokir build. Validasi pakai `flutter build apk --debug`
- Emulator tidak dipakai. Testing lewat `adb devices` + `flutter run -d <id>`; opsi wireless `adb pair`

## Device test

| Model | Versi Android | Catatan |
|---|---|---|
| POCO X6 Pro 5G (`2311DRK48G`, codename `duchamp`) | **Android 16 (API 36)**, HyperOS 3.0 (`OS3.0.302.0.WNLIDXM`) | adb id `AUZT6T5X7TCAHUX4`. Timezone `Asia/Jakarta`, locale `en-US` |

Device ini kebetulan kombinasi terberat yang bisa didapat: **Xiaomi/HyperOS**
(OEM paling agresif membunuh background) di **Android 16** (aturan exact alarm
dan foreground service paling ketat). Kalau adzan bunyi di sini, di HP lain
hampir pasti aman.

### Yang sudah terverifikasi di device ini

| | Bukti |
|---|---|
| Akurasi jadwal | ≤1 menit vs jadwal Kemenag Kota Malang. GPS jatuh di Kabupaten Malang, jadi sebagian selisih itu beda titik, bukan algoritma |
| Timezone | Dikalibrasi di Mac UTC+8, benar di HP UTC+7 |
| Penjadwalan | 35 alarm = 7 hari × 5 waktu, `RTC_WAKEUP`, `window=0` |
| Exact alarm | `exactAllowReason=policy_permission` — `USE_EXACT_ALARM` dihormati tanpa prompt |
| Channel adzan | `mSound=android.resource://com.cevin.tanbih/raw/adhan_short` |
| Bunyi adzan | Dikonfirmasi terdengar saat notifikasi muncul |

### Catatan khas HyperOS

`Geolocator.isLocationServiceEnabled()` mengembalikan **false** padahal
`cmd location is-location-enabled` = true dan `location_mode` = 3. Dulu ini
dipakai sebagai gate sebelum meminta posisi, dan memblokir semua fix. Sekarang
hanya dipakai *setelah* percobaan gagal, untuk menyusun pesan error.

## Sumber referensi

- Jadwal acuan uji akurasi: https://bimasislam.kemenag.go.id/jadwalshalat (toleransi ±1 menit)
- Pola arsitektur diambil dari `~/Developer/lessworry-mobile`

## Deviasi dari desain (disengaja, dicatat untuk ditinjau ulang)

| Bagian | Deviasi | Alasan |
|---|---|---|
| Watermark baris jadwal | SVG 561 KB (satu path) diganti PNG 10 KB hasil render Figma | Merender path sebesar itu 5× per layar adalah risiko jank yang persis diperingatkan di plan |
| Ikon tile Menu | Pakai Material Icons, bukan ikon Figma | 5 dari 6 tile berstatus "Segera". Ikon aslinya diexport saat fiturnya dibangun |
| Splash | Native splash mengikuti tema (mark + wordmark), bukan layar Dart | Frame splash Figma (`1:44`) memakai nama app lain, warnanya (magenta/oranye) di luar palet Tanbih, dan sejak Android 12 sistem yang menggambar splash — ilustrasi bebas tidak diizinkan. Latar splash disamakan dengan latar Home per tema, jadi masuk aplikasi tanpa kedip |
| Baris "Other" di Menu | Ditandai "Segera" | Feedback/Rate/Share/Support membuka target di luar app; wiring-nya di phase rilis |
| Qibla | Masih "Segera" di Menu | Dibangun di phase-nya sendiri bersama `flutter_qiblah` |
| Dark mode | Diturunkan dari navy brand board | Desain belum menyediakan varian gelap — **butuh review** |

## Phase 8 (Silent Settings) — ditunda, keputusan sudah dikunci

Dikerjakan setelah Phase 9 (Qibla) dan Phase 10 (polish rilis), supaya ada
versi yang bisa dirilis ke internal testing tanpa bergantung padanya. Alasan
penundaan: friksi izinnya paling tinggi dan ia satu-satunya fitur yang kalau
bug bisa **meninggalkan HP pengguna senyap permanen**.

Keputusan yang sudah diambil:

| Aspek | Keputusan | Alasan |
|---|---|---|
| Mekanisme | `setInterruptionFilter(INTERRUPTION_FILTER_ALARMS)` — **bukan** ringer mode | Hanya satu nilai yang diubah, jadi pemulihannya bersih. Alarm dan adzan (`USAGE_ALARM`) tetap lolos. Ringer mode menyentuh volume sistem dan lebih sering dibatasi HyperOS |
| Mulai senyap | Default `startOffsetMinutes = 3`, yaitu **setelah adzan selesai** | Menghindari balapan antara senyap dan adzan di instan yang sama. Yang perlu hening itu shalatnya, bukan adzannya |

Catatan implementasi yang sudah dipastikan sebelum mulai:

- `ACCESS_NOTIFICATION_POLICY` **bukan** runtime permission — tidak ada dialog.
  User harus menyalakannya manual di Settings → Special app access → Do Not
  Disturb access. Kita hanya bisa deep-link ke
  `ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS`. `permission_handler` tidak bisa
- **Dua alarm per waktu** (masuk senyap + pulihkan). Tidak boleh pakai timer
  in-app: app akan dibunuh di antara keduanya
- Window senyap dipendekkan jadi **2 hari** (bukan 7), diperpanjang tiap app
  dibuka — kalau 7 hari, bertambah 70 alarm di atas 65 yang sudah ada
- Mode sebelumnya disimpan di SharedPreferences **native**, supaya receiver
  pemulihan tetap tahu tujuannya walau app sudah mati
- Saat app dibuka: kalau state bilang "kami menyenyapkan" tapi waktu pulih
  sudah lewat → pulihkan seketika. Ini jaring pengaman untuk force-stop, yang
  membatalkan semua alarm
- `setInterruptionFilter` **belum pernah diuji di HyperOS**. Ada kemungkinan
  nyata Xiaomi membatasinya; itu harus diuji lebih dulu sebelum membangun UI-nya
