# Kredit Aset Audio

Setiap rekaman adzan yang dibundel atau diunduh **wajib** tercatat di sini
dengan sumber dan lisensinya. Aset tanpa lisensi yang jelas tidak boleh masuk
ke repo atau ke katalog unduhan.

## Yang dibundel

| File | Sumber | Lisensi | Durasi |
|---|---|---|---|
| `assets/audio/adhan_full.ogg` | ["Beautiful adhan"](https://commons.wikimedia.org/wiki/File:Beautiful_adhan.ogg) oleh Adam-synagda, Wikimedia Commons (2022) | **CC0 1.0** — Public Domain Dedication | 2:32 |
| `android/app/src/main/res/raw/adhan_short.ogg` | Potongan dari file yang sama | **CC0 1.0** | 0:30 |

CC0 tidak mewajibkan atribusi. Kredit di sini dan di layar About tetap
dicantumkan sebagai penghormatan ke pengunggah, bukan karena kewajiban lisensi.

### Pemrosesan yang dilakukan

Sumber: Ogg Vorbis 154 detik, stereo 44.1 kHz, ~63 kbps, puncak −2,2 dBFS.

- Senyap awal 0,8 detik dibuang agar adzan langsung terdengar
- Di-*downmix* ke mono — ponsel memutarnya lewat satu speaker, dan mono
  memangkas separuh ukuran di APK
- Level dibiarkan apa adanya; puncak −2,2 dBFS sudah pas tanpa normalisasi
- **Clip 30 detik dipotong pada jeda alami di detik 30,5–31,0**, bukan
  dipotong sembarang di tengah kalimat, dengan *fade out* 0,25 detik
- 30,0 detik juga batas keras iOS untuk custom notification sound, jadi clip
  ini tetap terpakai kalau iOS digarap nanti
- Di-encode ulang Ogg Vorbis mono kualitas 2 (~96 kbps)

Dikerjakan dengan `oggdec`/`oggenc` (vorbis-tools) dan Python stdlib.

## Yang masih kurang: adzan Subuh

Adzan Subuh berbeda dari adzan waktu lain. Setelah *hayya 'alal falah* ada
tambahan **tatswib** — الصلاة خير من النوم, *"shalat lebih baik daripada
tidur"* — dibaca dua kali, dan hanya ada di Subuh. Memutar adzan biasa saat
Subuh terdengar salah bagi siapa pun yang terbiasa mendengarnya.

Rekaman yang kita bundel sekarang **adzan biasa, bukan Subuh**. Diperiksa
dengan memecah rekaman berdasarkan jeda: terdeteksi 12 frasa, yang cocok
dengan struktur adzan biasa (takbir 4× jadi 2 frasa, syahadat 2+2, hayya 2+2,
takbir 2×, tahlil). Kalau ada tatswib, jumlahnya sekitar 14.

Sampai ada rekaman bertatswib yang lisensinya jelas, Subuh memutar rekaman
yang sama. Ini dinyatakan di kode lewat `AdhanVariant.usesFallbackRecording`,
bukan dibiarkan jadi kebetulan.

### Sumber yang sudah dicari dan hasilnya

| Sumber | Hasil |
|---|---|
| Wikimedia Commons | Tidak ada adzan Subuh sama sekali |
| Internet Archive | Banyak, **tidak satu pun menyatakan lisensi**. Isinya rekaman qari terkenal yang diunggah orang lain — kemungkinan besar berhak cipta |
| Freesound (CC0) | Ada 26 rekaman adzan CC0, tapi semuanya rekaman lapangan: terekam dari kejauhan, ada suara AC dan suara kafe. Tidak layak dipakai sebagai adzan aplikasi |

Jalan yang paling bersih: merekam sendiri, atau meminta izin ke masjid untuk
memakai rekaman muadzinnya. Lisensinya jelas dan kualitasnya terkendali.

## Yang ditolak

| File | Alasan |
|---|---|
| ["Call to prayer by Sabah Fakhry"](https://commons.wikimedia.org/wiki/File:Call_to_prayer_by_Sabah_Fakhry.mp3) | Ditandai Public Domain di Commons, **tapi klaimnya tidak sah**: sumbernya ripped dari YouTube, rekamannya tahun 1985, ditag `PD-Old`/`PD-US-expired` dengan alasan "adzan sudah ada sejak 622 M". Yang berumur 1400 tahun adalah lafaznya, bukan rekaman suaranya. Sabah Fakhri wafat 2021 |

## Aturan

- Hanya rekaman public domain atau berlisensi yang mengizinkan redistribusi
- **Periksa alasan lisensinya, bukan cuma tag-nya** — kasus di atas buktinya
- CC BY-SA boleh dipakai, tapi ingat sifat copyleft-nya: potongan/transcode
  dari file CC BY-SA ikut wajib CC BY-SA
- Cantumkan atribusi di layar About aplikasi, bukan hanya di file ini
- Format Android: `.ogg` mono di `android/app/src/main/res/raw/`
- Clip notifikasi maksimal 30 detik (batas keras iOS, dan tetap dipakai untuk
  channel notifikasi Android)
