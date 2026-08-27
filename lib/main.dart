import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:eposwa/core/theme/app_theme.dart';
import 'package:eposwa/core/widgets/app_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Aktifkan frameless window hanya di Desktop (Windows/Linux/macOS).
  // Di Web & Mobile tetap pakai title bar sistem.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden, // hilangkan tombol silang/min/max sistem
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      // Optional: cegah ukuran terlalu kecil
      await windowManager.setMinimumSize(const Size(900, 600));
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ePOSWA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppSplashScreen(),
    );
  }
}
