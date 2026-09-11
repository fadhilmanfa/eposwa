import 'package:eposwa/core/services/update_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Perbandingan versi menentukan kapan tombol Update menawarkan pembaruan,
/// jadi salah baca tag rilis bisa membuat update tidak pernah muncul atau
/// justru muncul terus. Seluruh test di sini murni tanpa jaringan.
void main() {
  group('parseVersion', () {
    test('membaca versi polos dan versi berbuild', () {
      expect(UpdateService.parseVersion('v1.0.1').parts, [1, 0, 1]);
      expect(UpdateService.parseVersion('v1.0.1').build, 0);

      final withBuild = UpdateService.parseVersion('1.0.0+1');
      expect(withBuild.parts, [1, 0, 0]);
      expect(withBuild.build, 1);
    });

    test('bagian non-angka dihitung nol tanpa melempar exception', () {
      expect(UpdateService.parseVersion('vabc').parts, [0]);
      expect(UpdateService.parseVersion('vabc').build, 0);
      expect(UpdateService.parseVersion('').parts, [0]);
      expect(UpdateService.parseVersion('1.x.0').parts, [1, 0, 0]);
    });
  });

  group('compareVersions', () {
    test('versi lebih baru menghasilkan nilai positif', () {
      expect(UpdateService.compareVersions('1.0.1', '1.0.0+1'), greaterThan(0));
      expect(UpdateService.compareVersions('1.0.0', '1.0.1'), lessThan(0));
    });

    test('nomor build jadi penentu bila versinya sama', () {
      expect(UpdateService.compareVersions('1.0.0+1', 'v1.0.0'), greaterThan(0));
      expect(UpdateService.compareVersions('v1.0.0', '1.0.0'), 0);
    });

    test('dibandingkan sebagai angka, bukan teks', () {
      expect(UpdateService.compareVersions('1.10.0', '1.9.0'), greaterThan(0));
      expect(UpdateService.compareVersions('2.0.0', '10.0.0'), lessThan(0));
    });

    test('jumlah bagian yang berbeda disamakan dengan nol', () {
      expect(UpdateService.compareVersions('1.1', '1.1.0'), 0);
      expect(UpdateService.compareVersions('1.1.0.0', '1.1'), 0);
    });
  });

  group('UpdateCheckResult', () {
    test('canInstall hanya benar bila ada rilis dan berkas installer', () {
      const withoutAsset = UpdateCheckResult(
        hasUpdate: true,
        currentVersion: '1.0.0+1',
        latestVersion: '1.0.1',
      );
      const ready = UpdateCheckResult(
        hasUpdate: true,
        currentVersion: '1.0.0+1',
        latestVersion: '1.0.1',
        downloadUrl: 'https://example.com/setup.exe',
        assetName: 'ePOSWA-1.0.1-Setup.exe',
      );

      expect(withoutAsset.canInstall, isFalse);
      expect(ready.canInstall, isTrue);
    });
  });
}
