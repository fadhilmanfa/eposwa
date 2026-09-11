; ePOSWA - Template script installer Windows (Inno Setup 6)
;
; JANGAN dipakai langsung. Token @...@ diisi otomatis oleh:
;     dart run tool/build_installer.dart
; Hasil render + installer ada di build\windows\x64\installer\.
;
; AppId sengaja dipertahankan sama seperti installer versi sebelumnya supaya
; instalasi lama terdeteksi sebagai upgrade, bukan aplikasi baru.

[Setup]
AppId=9fc9e029-c2e1-4176-a798-63a310d75be7
AppName=ePOSWA
AppVersion=@APP_VERSION@
AppVerName=ePOSWA @APP_VERSION@
AppPublisher=Keperawatan UMS
DefaultDirName={autopf}\ePOSWA
DefaultGroupName=ePOSWA
DisableProgramGroupPage=yes
; Update in-app: aplikasi menutup diri sebelum wizard diproses, jadi Restart
; Manager tidak perlu menghidupkan ulang app (cukup checkbox di halaman Finish).
CloseApplications=yes
RestartApplications=no
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequiredOverridesAllowed=dialog
MinVersion=10.0.10240
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
OutputDir=@OUTPUT_DIR@
OutputBaseFilename=ePOSWA-@APP_VERSION@-Setup
SetupIconFile=@ASSET_DIR@\setup.ico
UninstallDisplayIcon={app}\eposwa.exe
UninstallDisplayName=ePOSWA
; Aset panel wajib BMP: compiler Inno Setup yang dipakai belum mendukung PNG.
WizardImageFile=@ASSET_DIR@\wizard-100.bmp,@ASSET_DIR@\wizard-125.bmp,@ASSET_DIR@\wizard-150.bmp,@ASSET_DIR@\wizard-200.bmp
WizardSmallImageFile=@ASSET_DIR@\wizard-small-100.bmp,@ASSET_DIR@\wizard-small-150.bmp,@ASSET_DIR@\wizard-small-200.bmp,@ASSET_DIR@\wizard-small-250.bmp
VersionInfoVersion=@APP_VERSION@.@BUILD_NUMBER@
VersionInfoCompany=Keperawatan UMS
VersionInfoDescription=ePOSWA Setup
VersionInfoProductName=ePOSWA
VersionInfoProductVersion=@APP_VERSION@

[Languages]
Name: "id"; MessagesFile: "compiler:Languages\Indonesian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Berkas database TIDAK ada di sini: eposwa.db tersimpan di
; %APPDATA%\com.example\eposwa\ (lihat lib/core/database/app_database.dart), di
; luar folder instalasi, sehingga update maupun uninstall tidak pernah
; menyentuhnya. Jangan menambahkan [UninstallDelete] ke folder data pengguna.
; *.msix diabaikan: berkas itu sisa dari `msix:create` di folder build yang sama
; dan tidak boleh ikut terbawa ke dalam installer.
Source: "@SOURCE_DIR@\*"; DestDir: "{app}"; Excludes: "*.msix,*.pdb"; Flags: ignoreversion recursesubdirs createallsubdirs
; Runtime Visual C++ dipasang app-local supaya aplikasi tetap jalan di PC
; yang belum memiliki VC++ Redistributable.
Source: "@ASSET_DIR@\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "@ASSET_DIR@\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "@ASSET_DIR@\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\ePOSWA"; Filename: "{app}\eposwa.exe"
Name: "{autodesktop}\ePOSWA"; Filename: "{app}\eposwa.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\eposwa.exe"; Description: "{cm:LaunchProgram,ePOSWA}"; Flags: nowait postinstall skipifsilent
