import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eposwa/core/theme/app_theme.dart';
import 'package:eposwa/features/beranda/presentation/pages/beranda_page.dart';

void main() {
  testWidgets('Beranda minimalist layout renders correctly on desktop resolution', (WidgetTester tester) async {
    // Set screen size (desktop resolution 1080p)
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const BerandaPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Brand and Navbar
    expect(find.text('ePOSWA'), findsWidgets);
    expect(find.text('Masuk'), findsOneWidget);

    // Hero Section
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Selamat Datang'),
      ),
      findsOneWidget,
    );

    // Floating Services Grid (3 Cards)
    expect(find.text('Pendaftaran Pasien'), findsWidgets);
    expect(find.text('Skrining Jiwa Mandiri'), findsOneWidget);
    expect(find.text('Database & Rekapitulasi'), findsOneWidget);

    // Minimalist Footer
    expect(find.text('© 2026 ePOSWA. All rights reserved.'), findsOneWidget);
    expect(find.text('Versi v1.0.0'), findsOneWidget);
  });
}
