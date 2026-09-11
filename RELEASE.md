# Checklist Rilis — Tanbih

Daftar kerja Phase 10. Kolom **Siapa** menandai yang hanya bisa dikerjakan
Cevin (kunci, akun, hosting) versus yang bisa dikerjakan di repo.

Tanda 🔴 = memblokir rilis. Tanda 🟡 = boleh menyusul, tapi jangan lama.

---

## 1. Yang bisa merusak diam-diam

Build release memangkas dan mengganti nama kode. Receiver dan service adzan
dipanggil lewat nama dari `AndroidManifest.xml`, bukan dari kode Dart — kalau
namanya diubah, Android tidak menemukannya. Aplikasi tetap jalan normal,
jadwal tetap tampil, **adzan tidak pernah bunyi**, dan tidak ada error apa pun.
Cuma muncul di release.

| | Kerjaan | Siapa |
|---|---|---|
| 🔴 | Tulis aturan R8/ProGuard supaya nama receiver, service, dan boot receiver tidak diubah | repo |
| 🔴 | Build release, pasang di HP, tekan tombol tes alarm 20 detik, pastikan adzan bunyi | repo + HP |
| 🔴 | Tes juga notifikasi terjadwal di release (tunggu satu waktu shalat asli) | HP |
| 🟡 | Pastikan baris debug "Test scheduled adhan" tidak muncul di release | repo |

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
