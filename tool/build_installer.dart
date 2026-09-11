import 'dart:convert';
import 'dart:io';

import 'pubspec_version.dart';

/// Build installer Windows ePOSWA (Flutter build + Inno Setup).
///
/// Jalankan dari mana saja:
///   dart run tool/build_installer.dart
///   dart run tool/build_installer.dart --skip-build
///
/// Versi diambil dari `version:` pada pubspec.yaml sehingga tidak perlu
/// diperbarui manual di script installer.
Future<void> main(List<String> args) async {
  final skipBuild = args.contains('--skip-build');
  final root = Directory(File.fromUri(Platform.script).parent.parent.path).path;

  final version = readPubspecVersion(root);
  final appVersion = version.parts.join('.');

  final sourceDir = '$root\\build\\windows\\x64\\runner\\Release';
  final outputDir = '$root\\build\\windows\\x64\\installer';
  final assetDir = '$root\\windows\\installer\\assets';

  stdout.writeln('ePOSWA installer builder');
  stdout.writeln('  versi       : $appVersion+${version.build}');
  stdout.writeln('  sumber build: $sourceDir');

  if (!skipBuild) {
    stdout.writeln('\n[1/3] flutter build windows --release');
    final build = await Process.run(
      'flutter',
      ['build', 'windows', '--release'],
      workingDirectory: root,
      runInShell: true,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (build.exitCode != 0) {
      stderr
        ..writeln(build.stdout)
        ..writeln(build.stderr);
      fail('flutter build gagal (exit ${build.exitCode}).');
    }
    stdout.writeln(build.stdout);
  } else {
    stdout.writeln('\n[1/3] flutter build dilewati (--skip-build)');
  }

  if (!File('$sourceDir\\eposwa.exe').existsSync()) {
    fail(
      'Hasil build tidak ditemukan di $sourceDir. '
      'Jalankan flutter build windows --release.',
    );
  }

  stdout.writeln('\n[2/3] render script installer');
  final template = File('$root\\windows\\installer\\eposwa.iss');
  if (!template.existsSync()) {
    fail('Template tidak ditemukan: ${template.path}');
  }
  final rendered = template.readAsStringSync().replaceAllMapped(
    RegExp(r'@([A-Z_]+)@'),
    (match) => switch (match.group(1)) {
      'APP_VERSION' => appVersion,
      'BUILD_NUMBER' => version.build,
      'SOURCE_DIR' => sourceDir,
      'OUTPUT_DIR' => outputDir,
      'ASSET_DIR' => assetDir,
      _ => match.group(0)!,
    },
  );

  Directory(outputDir).createSync(recursive: true);
  final script = File('$outputDir\\eposwa.iss')..writeAsStringSync(rendered);
  stdout.writeln('  ${script.path}');

  stdout.writeln('\n[3/3] compile installer');
  final iscc = _findCompiler(root);
  if (iscc == null) {
    fail(
      'ISCC.exe tidak ditemukan. Install Inno Setup 6 atau tambahkan '
      'inno_build ke dependencies.',
    );
  }
  stdout.writeln('  compiler: $iscc');

  final compile = await Process.run(
    iscc,
    ['/Qp', script.path],
    runInShell: true,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  if (compile.exitCode != 0) {
    stderr
      ..writeln(compile.stdout)
      ..writeln(compile.stderr);
    fail('Compile installer gagal (exit ${compile.exitCode}).');
  }

  final installer = File('$outputDir\\ePOSWA-$appVersion-Setup.exe');
  if (!installer.existsSync()) {
    fail(
      'Compile selesai tapi file installer tidak ditemukan di '
      '${installer.path}.',
    );
  }
  final mb = (installer.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
  stdout.writeln('\nSelesai: ${installer.path} ($mb MB)');
}

/// Cari ISCC.exe: paket inno_build lebih dulu, lalu instalasi Inno Setup, lalu PATH.
String? _findCompiler(String root) {
  final candidates = <String>[
    ..._fromInnoBuildPackage(root),
    '${Platform.environment['ProgramFiles(x86)']}\\Inno Setup 6\\ISCC.exe',
    '${Platform.environment['ProgramFiles']}\\Inno Setup 6\\ISCC.exe',
    'ISCC.exe',
  ];
  for (final path in candidates) {
    if (path == 'ISCC.exe' || File(path).existsSync()) {
      return path;
    }
  }
  return null;
}

Iterable<String> _fromInnoBuildPackage(String root) sync* {
  final config = File('$root\\.dart_tool\\package_config.json');
  if (!config.existsSync()) {
    return;
  }
  final decoded = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  for (final entry in (decoded['packages'] as List).cast<Map<String, dynamic>>()) {
    if (entry['name'] != 'inno_build') {
      continue;
    }
    final uri = config.parent.uri.resolve(entry['rootUri'] as String);
    yield '${File.fromUri(uri).path}\\lib\\assets\\ISCC.exe';
  }
}
