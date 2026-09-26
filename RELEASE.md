# Checklist Rilis — Tanbih

Daftar kerja Phase 10. Kolom **Siapa** menandai yang hanya bisa dikerjakan
Cevin (kunci, akun, hosting) versus yang bisa dikerjakan di repo.

Tanda 🔴 = memblokir rilis. Tanda 🟡 = boleh menyusul, tapi jangan lama.

---

## 1. R8 — sudah dikerjakan, sisa satu pembuktian

**Koreksi dari versi pertama checklist ini.** Semula di sini tertulis bahwa
R8 akan mengganti nama receiver dan service adzan sehingga Android tidak
menemukannya. **Itu salah.** R8 membaca `AndroidManifest.xml` dan
memperlakukan apa pun yang terdaftar di sana sebagai titik masuk yang tidak
boleh diubah. Dibuktikan lewat `build/app/outputs/mapping/release/mapping.txt`:

```
AdhanAlarmReceiver    -> AdhanAlarmReceiver      (tetap)
BootReceiver          -> BootReceiver            (tetap)
AdhanPlaybackService  -> AdhanPlaybackService    (tetap)
AdhanAlarmScheduler   -> B1.c                    (di-rename, tidak masalah)
```

Yang di-rename hanya kelas internal, dan itu tidak apa-apa karena cuma
dipanggil dari kode Kotlin, bukan lewat nama.

Risiko yang **nyata** ternyata di tempat lain: plugin notifikasi menyimpan
daftar jadwalnya sebagai JSON lewat Gson, dan Gson memakai **nama field**
sebagai kunci JSON. Kalau R8 mengganti nama field, kunci JSON ikut berubah.
Dalam satu build tetap konsisten sehingga tidak kelihatan — kerusakannya
muncul saat **update aplikasi**, waktu JSON tulisan versi lama dibaca versi
baru yang menamai field berbeda. Semua notifikasi terjadwal hilang tanpa
error, sampai user kebetulan membuka aplikasi lagi.

| | Kerjaan | Status |
|---|---|---|
| ✅ | `proguard-rules.pro` dengan keep rules untuk `com.dexterous.**` dan Gson | selesai |
| ✅ | `isMinifyEnabled` + `isShrinkResources` dinyatakan eksplisit di build.gradle.kts | selesai |
| ✅ | Verifikasi lewat mapping.txt: nol kelas plugin notifikasi ter-rename | selesai |
| 🔴 | Pasang build release di HP, tekan tes alarm 20 detik, pastikan adzan bunyi | butuh HP |
| 🔴 | Pasang ulang APK yang sama **tanpa membuka aplikasi**, hitung alarm sebelum dan sesudah | butuh HP |
| 🔴 | Tunggu satu waktu shalat asli di build release | butuh HP |

Tes kedua itu yang paling berharga. Memasang ulang APK memicu
`MY_PACKAGE_REPLACED` — jalur yang sama persis dengan pemulihan setelah
reboot — jadi ia menguji baik penyimpanan native kita maupun penyimpanan
Gson milik plugin, tanpa perlu me-reboot HP.

Catatan: `adb shell am force-stop` **membatalkan semua alarm**. Jangan
dipakai di tengah pengujian ini, nanti yang terukur bukan yang dimaksud.

## 2. Yang hanya bisa dikerjakan Cevin

| | Kerjaan | Catatan |
|---|---|---|
| 🔴 | Buat keystore (kunci penandatangan) | Dibuat sekali, dipakai selamanya. **Hilang = tidak bisa update aplikasi lagi, selamanya.** Backup ke tempat aman, jangan masuk Git |
| 🔴 | Simpan password keystore | Jangan ditaruh di repo, jangan dikirim ke siapa pun termasuk ke sesi ini |
| 🔴 | Akun Google Play Console | Bayar sekali 25 USD |
| 🔴 | Hosting halaman kebijakan privasi | Butuh alamat web publik. GitHub Pages cukup. Isinya bisa disiapkan di repo |
| 🟡 | Kumpulkan 3–5 orang untuk internal testing | Usahakan merek HP berbeda-beda |

## 3. Materi toko

| | Kerjaan | Siapa |
|---|---|---|
| 🔴 | Ikon 512×512 untuk Play Store | repo (export dari brand board) |
| 🔴 | Feature graphic 1024×500 | repo |
| 🔴 | Screenshot minimal 2, idealnya 4–6 | ambil dari HP |
| 🔴 | Judul + deskripsi pendek + deskripsi panjang, Indonesia dan Inggris | repo, Cevin koreksi |
| 🔴 | Isi formulir Data Safety | Cevin. Jawabannya: lokasi dipakai, tidak dikirim ke server, tidak dibagikan |
| 🔴 | Content rating questionnaire | Cevin |
| 🔴 | Siapkan alasan izin `USE_EXACT_ALARM` | repo tulis draf, Cevin submit. Tanbih memang aplikasi alarm/pengingat, jadi memenuhi syarat |

## 4. Rapi-rapi

| | Kerjaan | Siapa |
|---|---|---|
| 🔴 | Layar "Tentang": atribusi adzan (CC0), font Outfit + Poppins (OFL), data kota dari OpenStreetMap (ODbL) | repo. **Dua terakhir kewajiban lisensi, bukan sopan santun** |
| 🟡 | Audit semua teks ada di dua bahasa, tidak ada yang bolong | repo |
| 🟡 | Cek aplikasi masih terbaca saat ukuran font HP dibesarkan | repo + HP |
| 🟡 | Cek kontras teks putih di atas gradient | repo |
| 🟡 | Profil performa layar Home di build release (glassmorphism berat) | HP |
| 🟡 | Integration test alur utama: buka → izin → jadwal tampil → notifikasi | repo |
| 🟡 | `CHANGELOG.md` dan versi `1.0.0+1` | repo |

## 5. Rilis

| | Kerjaan | Siapa |
|---|---|---|
| 🔴 | Build `appbundle` release yang sudah ditandatangani | repo |
| 🔴 | Upload ke jalur **internal testing** dulu, bukan production | Cevin |
| 🔴 | Kumpulkan hasil tes dari beberapa HP, terutama merek selain Xiaomi | Cevin |
| 🟡 | Baru naikkan ke production | Cevin |

---

## Urutan yang disarankan

Kerjakan bagian 1 dan 4 dulu — semuanya bisa jalan tanpa keystore dan tanpa
akun Play Console. Bagian 1 yang paling mendesak karena bug diam-diamnya
paling berbahaya.

Bagian 2 dan 3 jalan paralel begitu Cevin siap.
