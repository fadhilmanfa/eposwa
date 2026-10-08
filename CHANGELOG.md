#CHANGELOG

## 1.0.0.0 - first build
### Store
- none

## Unreleased — Sambungkan PC (sinkronisasi antar laptop)
- Menu "Sambungkan PC" kini membuka dialog sinkronisasi dua-arah via
  WiFi/tethering hotspot (UDP 42421 discovery + TCP 42420, hotspot Windows
  otomatis): satu tap "Sinkronkan" menukar dump SQL (opcode 0x03) dan kedua
  laptop berakhir identik (union).
- Menu "Instan" kini membuka alur Berbagi Instan yang sudah ada (Kirim/Terima
  + preview + apply selektif per-NIK); sebelumnya keduanya placeholder.
- Kebijakan data A/B: langsung digabung — NIK baru ditambah, NIK sama
  digabung (hanya field kosong yang diisi, tidak ada data hilang), tanpa
  kolom asal. Asal hanya tampil sebagai angka ringkasan di dialog hasil.
- Import skrining kini opsional idempoten (`dedupeSkrining`) sehingga sync
  berulang tidak menggandakan baris; perilaku import file lama tidak berubah.
