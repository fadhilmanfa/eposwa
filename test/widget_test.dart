import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eposwa/main.dart';

void main() {
  testWidgets('Beranda full replika smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // AppBar putih mirip gambar - nav items
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Tentang'), findsOneWidget);
    expect(find.text('Kontak'), findsOneWidget);

    // Jumbotron ngotak - tetap selamat datang (RichText)
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Selamat Datang'),
      ),
      findsOneWidget,
    );
    expect(find.text('Kelola pendaftaran dan data dengan mudah'), findsOneWidget);
    expect(find.text('DAFTAR SEKARANG'), findsOneWidget);

    // 3 menu flat tetap pendaftaran/test/database
    expect(find.text('Pendaftaran'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Database'), findsOneWidget);
    expect(find.byIcon(Icons.hearing_rounded), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);

    // Artikel section
    expect(find.text('Artikel Pilihan Anda'), findsWidgets);
    expect(find.text('Apa itu kesehatan Mental?'), findsWidgets);

    // Footer
    expect(find.text('Kontak Kami'), findsOneWidget);
    expect(find.text('Alamat Kami'), findsOneWidget);
  });
}
