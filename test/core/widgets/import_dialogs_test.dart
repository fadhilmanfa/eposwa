import 'package:eposwa/core/services/import_service.dart';
import 'package:eposwa/core/widgets/import_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _lama = ImportCandidate(
  nik: '111',
  nama: 'Andi',
  kodePeserta: 'REG-A',
  isExisting: true,
  skriningCount: 2,
);

const _baru = ImportCandidate(
  nik: '222',
  nama: 'Budi',
  kodePeserta: 'REG-B',
  isExisting: false,
  skriningCount: 0,
);

Future<void> _openDialog<T>(
  WidgetTester tester,
  Future<T> Function(BuildContext context) show,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => show(context),
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('buka'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('modal pilih user mengembalikan NIK yang dicentang saja', (
    tester,
  ) async {
    Set<String>? hasil;
    await _openDialog(tester, (context) async {
      hasil = await showImportCandidatesDialog(context, const [_lama, _baru]);
    });

    expect(find.text('Import Data'), findsOneWidget);
    expect(find.text('File berisi 2 peserta — 1 baru, 1 sudah ada.'), findsOneWidget);
    expect(find.text('Sudah ada'), findsOneWidget);
    expect(find.text('Baru'), findsOneWidget);
    // buang centang peserta pertama lewat barisnya
    await tester.tap(find.text('Andi'));
    await tester.pumpAndSettle();
    expect(find.text('Import (1)'), findsOneWidget);

    await tester.tap(find.text('Import (1)'));
    await tester.pumpAndSettle();

    expect(hasil, {'222'});
  });

  testWidgets('modal konflik mengembalikan aksi per user', (tester) async {
    Map<String, ImportStrategy>? hasil;
    await _openDialog(tester, (context) async {
      hasil = await showImportConflictDialog(context, const [_lama]);
    });

    expect(find.text('Data Konflik'), findsOneWidget);
    expect(
      find.text('1 peserta sudah ada di database. Pilih tindakan untuk masing-masing.'),
      findsOneWidget,
    );
    expect(find.text('111  ·  2 skrining di file'), findsOneWidget);

    // Keterangan panjang di atas daftar sudah dihapus.
    expect(
      find.textContaining('Gabung: isi data yang masih kosong'),
      findsNothing,
    );

    await tester.tap(find.text('Ganti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(hasil, {'111': ImportStrategy.replace});
  });
}
