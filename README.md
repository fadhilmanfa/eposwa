# ePOSWA

Aplikasi desktop (Windows) untuk Posyandu Jiwa Digital — deteksi dini, pendampingan,
dan pengelolaan data kesehatan jiwa warga. Dibangun dengan Flutter.

## Menjalankan

```bash
flutter pub get
flutter run -d windows
```

## Build installer Windows

```bash
dart run tool/build_installer.dart
```

Perintah di atas menjalankan `flutter build windows --release` lalu mengompilasi
installer Inno Setup. Hasilnya:

```
build/windows/x64/installer/ePOSWA-<versi>-Setup.exe
```

Opsi:

```bash
dart run tool/build_installer.dart --skip-build   # pakai hasil build yang sudah ada
```

Versi installer diambil dari `version:` pada `pubspec.yaml`, jadi cukup ubah satu
tempat saat rilis.

### Bagian yang dipakai installer

| Berkas | Fungsi |
| --- | --- |
| `windows/installer/eposwa.iss` | Template script installer. Token `@...@` diisi otomatis oleh tool. |
| `windows/installer/assets/setup.ico` | Ikon berkas installer. |
| `windows/installer/assets/wizard-*.bmp` | Panel kiri wizard (per tingkat DPI). |
| `windows/installer/assets/wizard-small-*.bmp` | Panel kecil kanan atas wizard. |
| `windows/installer/assets/*.dll` | Runtime Visual C++ (dipasang app-local). |

Catatan:

- `AppId` pada template sengaja dipertahankan dari installer versi sebelumnya supaya
  instalasi lama terdeteksi sebagai upgrade, bukan aplikasi baru.
- Aset panel wizard harus **BMP**: compiler Inno Setup 6.3.3 belum menerima PNG.
- Ikon aplikasi (`windows/runner/resources/app_icon.ico`) dipakai untuk `eposwa.exe`,
  shortcut Start Menu, dan shortcut desktop.

### Prasyarat build installer

- Visual Studio dengan toolchain C++ (untuk `flutter build windows`).
- Compiler Inno Setup. Tool ini otomatis memakai `ISCC.exe` bawaan paket `inno_build`
  (sudah ada di dependencies), dan jatuh ke instalasi Inno Setup 6
  (`C:\Program Files (x86)\Inno Setup 6\ISCC.exe`) bila paket tidak ditemukan.

## Build paket MSIX

Paket `msix` sudah menangani semuanya (build Windows, bikin paket, tanda tangan),
jadi cukup perintah bawaan paketnya:

```bash
dart run msix:create -p "$(cat windows/signing/password.txt)"
```

Di PowerShell:

```powershell
dart run msix:create -p (Get-Content windows\signing\password.txt -Raw).Trim()
```

Hasilnya: `build/windows/x64/runner/Release/eposwa.msix`.

Konfigurasi ada di `msix_config` pada `pubspec.yaml`. Versi MSIX mengikuti
`version:` di pubspec secara otomatis, jadi tidak ada `msix_version` yang perlu
dirawat.

Catatan:

- Password sertifikat **tidak** ditulis di `pubspec.yaml`; berkas
  `windows/signing/` (berisi `.pfx` dan password) sudah masuk `.gitignore`.
- Naikkan `minor`/`patch` pada `version:` saat rilis. MSIX hanya memakai tiga angka
  pertama (`1.0.0+1` → `1.0.0.0`), jadi menaikkan nomor build saja tidak mengubah
  versi paket dan update tidak akan terdeteksi.
- Sertifikat harus dipercaya di tingkat **mesin**, bukan hanya pengguna. Bila
  `msix:create` tidak menawarkan pemasangan sertifikat (karena sudah ada di
  `CurrentUser`), pasang manual sebagai admin:

  ```powershell
  Import-Certificate -FilePath windows\signing\eposwa_cert.cer -CertStoreLocation Cert:\LocalMachine\TrustedPeople
  Import-Certificate -FilePath windows\signing\eposwa_cert.cer -CertStoreLocation Cert:\LocalMachine\Root
  ```

  Tanpa itu, `Add-AppxPackage` gagal dengan `0x800B0109` (root certificate not trusted).
