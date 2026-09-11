import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:eposwa/core/services/xlsx_writer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<int> buildSample() {
    return XlsxWriter.build([
      const XlsxSheet('Peserta', [
        ['Nama', 'Skor', 'Catatan'],
        ['Ahmad & Budi', 42, 'baik'],
        ['<Siti>', 2, null],
      ]),
      const XlsxSheet('Skrining', [
        ['Kategori'],
        ['rendah'],
      ]),
    ]);
  }

  String readEntry(List<int> bytes, String path) {
    final file = ZipDecoder().decodeBytes(bytes).findFile(path);
    expect(file, isNotNull, reason: 'entry $path harus ada');
    return utf8.decode(file!.content);
  }

  test('menghasilkan seluruh entry xlsx yang dibutuhkan Excel', () {
    final bytes = buildSample();
    for (final path in [
      '[Content_Types].xml',
      '_rels/.rels',
      'xl/workbook.xml',
      'xl/_rels/workbook.xml.rels',
      'xl/styles.xml',
      'xl/worksheets/sheet1.xml',
      'xl/worksheets/sheet2.xml',
    ]) {
      expect(
        ZipDecoder().decodeBytes(bytes).findFile(path),
        isNotNull,
        reason: 'entry $path hilang',
      );
    }
  });

  test('mendaftarkan nama setiap sheet di workbook.xml', () {
    final workbook = readEntry(buildSample(), 'xl/workbook.xml');
    expect(workbook, contains('name="Peserta"'));
    expect(workbook, contains('name="Skrining"'));
    expect(workbook, contains('r:id="rId1"'));
    expect(workbook, contains('r:id="rId2"'));
  });

  test('teks jadi inline string dan angka jadi sel numerik', () {
    final sheet = readEntry(buildSample(), 'xl/worksheets/sheet1.xml');
    expect(sheet, contains('t="inlineStr"'));
    expect(sheet, contains('<t xml:space="preserve">Ahmad &amp; Budi</t>'));
    expect(sheet, contains('<v>42</v>'));
    expect(sheet, contains('<v>2</v>'));
  });

  test('karakter khusus di-escape agar XML tetap valid', () {
    final sheet = readEntry(buildSample(), 'xl/worksheets/sheet1.xml');
    expect(sheet, contains('&lt;Siti&gt;'));
    expect(sheet, isNot(contains('<Siti>')));
  });

  test('sel null dilewati tanpa merusak baris', () {
    final sheet = readEntry(buildSample(), 'xl/worksheets/sheet1.xml');
    expect(sheet, contains('<row r="3"><c r="A3"'));
    expect(sheet, isNot(contains('r="C3"')));
  });

  test('baris header memakai style bold dan kolom punya lebar', () {
    final sheet = readEntry(buildSample(), 'xl/worksheets/sheet1.xml');
    expect(sheet, contains('<c r="A1" s="1"'));
    expect(sheet, contains('<cols>'));
    expect(sheet, contains('customWidth="1"'));
  });
}
