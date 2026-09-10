import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eposwa/core/theme/app_theme.dart';
import 'package:eposwa/features/auth/presentation/pages/login_page.dart';
import 'package:eposwa/features/beranda/presentation/pages/beranda_page.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_menu_card.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_menu_grid.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpBeranda(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const BerandaPage()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'seluruh area kartu menerima tap, termasuk bagian yang mengambang di atas jumbotron',
      (WidgetTester tester) async {
    await pumpBeranda(tester);

    final wrapper =
        tester.allRenderObjects.whereType<RenderOverlapWrapper>().first;
    final cardFinder = find.byType(BerandaMenuCard).first;
    // Kartu digeser naik sebesar overlap saat paint, jadi posisi visualnya
    // berada di atas box layout-nya.
    final visualRect = tester
        .getRect(cardFinder)
        .shift(Offset(0, -wrapper.overlap));
    final cardGesture = tester.renderObject(
      find.descendant(of: cardFinder, matching: find.byType(Listener)).first,
    );

    for (final fraction in <double>[0.02, 0.25, 0.5, 0.75, 0.98]) {
      final point = Offset(
        visualRect.center.dx,
        visualRect.top + visualRect.height * fraction,
      );
      final result = tester.hitTestOnBinding(point);
      expect(
        result.path.any((entry) => entry.target == cardGesture),
        isTrue,
        reason: 'Kartu harus bisa ditekan di y=${point.dy} '
            '(fraction=$fraction dari tinggi kartu)',
      );
    }
  });

  testWidgets('tap di bagian atas kartu membuka halaman login',
      (WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('window_manager'),
      (call) async => call.method == 'isMaximized' ? false : null,
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('window_manager'), null);
    });

    await pumpBeranda(tester);

    final wrapper =
        tester.allRenderObjects.whereType<RenderOverlapWrapper>().first;
    final visualRect = tester
        .getRect(find.byType(BerandaMenuCard).first)
        .shift(Offset(0, -wrapper.overlap));

    // 12px dari tepi atas kartu: area yang menimpa jumbotron.
    await tester.tapAt(Offset(visualRect.center.dx, visualRect.top + 12));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
