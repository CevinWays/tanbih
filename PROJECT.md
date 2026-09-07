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
| _(belum diisi)_ | | Isi setelah device pertama tercolok — perilaku alarm & DND beda antar OEM |

## Sumber referensi

- Jadwal acuan uji akurasi: https://bimasislam.kemenag.go.id/jadwalshalat (toleransi ±1 menit)
- Pola arsitektur diambil dari `~/Developer/lessworry-mobile`
