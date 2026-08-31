import 'package:flutter_test/flutter_test.dart';
import 'package:eposwa/features/skrining/domain/skrining_data.dart';

void main() {
  group('SkriningHasil.hitung - aturan Panduan Skrining', () {
    test('Q10 YA (red flag) -> KRITIS, skor Q1-9 diabaikan', () {
      final jawaban = [true, true, true, true, true, true, true, true, true, true];
      final hasil = SkriningHasil.hitung(jawaban);
      expect(hasil.kategori, SkriningKategori.kritis);
      expect(hasil.isRedFlag, isTrue);
      expect(hasil.skor, 0);
    });

    test('Q10 YA walau hanya 1 -> tetap KRITIS', () {
      final jawaban = [...List<bool?>.filled(9, false), true];
      final hasil = SkriningHasil.hitung(jawaban);
      expect(hasil.kategori, SkriningKategori.kritis);
      expect(hasil.isRedFlag, isTrue);
    });

    test('skor 0-2 -> Risiko Rendah', () {
      for (var skor = 0; skor <= 2; skor++) {
        final jawaban = _jawabanDenganSkor(skor);
        final hasil = SkriningHasil.hitung(jawaban);
        expect(hasil.kategori, SkriningKategori.rendah, reason: 'skor=$skor');
        expect(hasil.skor, skor);
        expect(hasil.isRedFlag, isFalse);
      }
    });

    test('skor 3-5 -> Risiko Sedang', () {
      for (var skor = 3; skor <= 5; skor++) {
        final jawaban = _jawabanDenganSkor(skor);
        final hasil = SkriningHasil.hitung(jawaban);
        expect(hasil.kategori, SkriningKategori.sedang, reason: 'skor=$skor');
        expect(hasil.skor, skor);
      }
    });

    test('skor 6-9 -> Risiko Tinggi', () {
      for (var skor = 6; skor <= 9; skor++) {
        final jawaban = _jawabanDenganSkor(skor);
        final hasil = SkriningHasil.hitung(jawaban);
        expect(hasil.kategori, SkriningKategori.tinggi, reason: 'skor=$skor');
        expect(hasil.skor, skor);
      }
    });

    test('rekomendasi kategori tidak kosong', () {
      final hasil = SkriningHasil.hitung(_jawabanDenganSkor(4));
      expect(hasil.rekomendasi, isNotEmpty);
    });
  });

  group('SkriningPertanyaan', () {
    test('berisi 10 pertanyaan, Q10 adalah red flag', () {
      expect(kSkriningPertanyaan.length, 10);
      expect(kSkriningPertanyaan[9].isRedFlag, isTrue);
      expect(kSkriningPertanyaan.where((q) => q.isRedFlag).length, 1);
    });
  });

  group('SkriningRecord', () {
    test('skorLabel menampilkan RED FLAG untuk kasus kritis', () {
      final record = SkriningRecord.fromHasil(
        nama: 'Test',
        tanggal: '01/09/2026',
        hasil: SkriningHasil.hitung(
          [...List<bool?>.filled(9, false), true],
        ),
      );
      expect(record.skorLabel, 'RED FLAG');
    });

    test('skorLabel menampilkan angka untuk kasus normal', () {
      final record = SkriningRecord.fromHasil(
        nama: 'Test',
        tanggal: '01/09/2026',
        hasil: SkriningHasil.hitung(_jawabanDenganSkor(3)),
      );
      expect(record.skorLabel, '3');
    });
  });
}

List<bool?> _jawabanDenganSkor(int skor) {
  return [
    for (var i = 0; i < 9; i++) i < skor,
    false,
  ];
}