# Kebijakan Privasi — Tanbih

Berlaku sejak: 26 September 2026

Tanbih adalah aplikasi pengingat waktu shalat. Dokumen ini menjelaskan data
apa yang disentuh aplikasi dan apa yang terjadi dengannya. Ringkasnya:
**aplikasi ini tidak punya server, dan tidak mengirim data Anda ke mana pun.**

## Lokasi

Tanbih memakai lokasi perangkat untuk menghitung waktu shalat, karena waktu
shalat berbeda menurut posisi geografis.

- Perhitungannya dilakukan **di dalam perangkat Anda**, memakai pustaka
  astronomi yang dibundel di dalam aplikasi
- Koordinat Anda **tidak pernah dikirim ke server mana pun**, termasuk ke
  pengembang
- Koordinat terakhir disimpan di penyimpanan lokal aplikasi supaya jadwal
  tetap muncul saat tidak ada internet, dan hilang saat aplikasi dihapus
- Aplikasi **tidak** meminta izin lokasi latar belakang. Lokasi hanya dibaca
  saat aplikasi dibuka

Anda bisa menolak izin lokasi sepenuhnya dan tetap memakai aplikasi dengan
memilih kota secara manual dari daftar yang sudah dibundel.

## Pencarian kota (opsional)

Jika Anda mengetik nama kota di pencarian, teks itu dikirim ke layanan
geocoding OpenStreetMap (Nominatim) untuk mendapatkan koordinatnya. Yang
dikirim hanya kata yang Anda ketik — bukan lokasi, bukan identitas Anda.

Fitur ini opsional. Tanpa internet, pencarian jatuh ke daftar kota Indonesia
yang sudah tersimpan di dalam aplikasi.

## Data yang tidak dikumpulkan

Tanbih tidak mengumpulkan, menyimpan, atau mengirimkan:

- Identitas, nama, email, atau nomor telepon
- Daftar kontak, foto, atau berkas
- Riwayat penggunaan, analitik, atau data perilaku
- Pengenal iklan

Tidak ada iklan, tidak ada pelacak pihak ketiga, dan tidak ada akun.

## Izin yang diminta dan alasannya

| Izin | Untuk apa |
|---|---|
| Lokasi (perkiraan & presisi) | Menghitung waktu shalat di posisi Anda |
| Notifikasi | Menampilkan pengingat saat waktu shalat masuk |
| Alarm presisi | Agar adzan berbunyi tepat waktu, bukan tertunda |
| Berjalan saat perangkat dinyalakan | Memasang ulang jadwal setelah perangkat di-restart |
| Layanan latar depan | Memutar adzan lengkap meski aplikasi ditutup |

## Penyimpanan

Semua pengaturan, lokasi terakhir, dan jadwal tersimpan di penyimpanan lokal
aplikasi di perangkat Anda. Menghapus aplikasi akan menghapus semuanya. Tidak
ada salinan di tempat lain.

## Anak-anak

Aplikasi ini tidak ditujukan khusus untuk anak-anak dan tidak mengumpulkan
data dari siapa pun, termasuk anak-anak.

## Perubahan

Jika kebijakan ini berubah, tanggal di atas akan diperbarui dan versi barunya
diterbitkan di alamat yang sama.

## Kontak

Pertanyaan soal kebijakan ini bisa dikirim ke pengembang melalui halaman
aplikasi di Google Play.
