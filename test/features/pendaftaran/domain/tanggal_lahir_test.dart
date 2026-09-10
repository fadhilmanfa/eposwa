import 'package:flutter_test/flutter_test.dart';
import 'package:eposwa/features/pendaftaran/domain/tanggal_lahir.dart';

void main() {
  group('TanggalLahir.format', () {
    test('mengembalikan null bila ada yang belum dipilih', () {
      expect(TanggalLahir.format(null, 9, 2000), isNull);
      expect(TanggalLahir.format(5, null, 2000), isNull);
      expect(TanggalLahir.format(5, 9, null), isNull);
    });

    test('format DD/MM/YYYY dengan padding nol', () {
      expect(TanggalLahir.format(5, 9, 2000), '05/09/2000');
      expect(TanggalLahir.format(17, 8, 1995), '17/08/1995');
    });
  });

  group('TanggalLahir.jumlahHari', () {
    test('Februari kabisat 29 hari, non-kabisat 28 hari', () {
      expect(TanggalLahir.jumlahHari(2000, 2), 29);
      expect(TanggalLahir.jumlahHari(2001, 2), 28);
    });

    test('bulan 30/31 hari', () {
      expect(TanggalLahir.jumlahHari(2026, 4), 30);
      expect(TanggalLahir.jumlahHari(2026, 1), 31);
    });
  });

  group('TanggalLahir.jepitTanggal', () {
    test('menjepit 31 ke Februari', () {
      expect(
        TanggalLahir.jepitTanggal(31, bulan: 2, tahun: 2001),
        28,
      );
      expect(
        TanggalLahir.jepitTanggal(31, bulan: 2, tahun: 2000),
        29,
      );
    });

    test('tidak mengubah tanggal yang masih valid', () {
      expect(TanggalLahir.jepitTanggal(15, bulan: 2, tahun: 2001), 15);
    });

    test('null tetap null', () {
      expect(TanggalLahir.jepitTanggal(null, bulan: 2, tahun: 2001), isNull);
    });
  });

  group('TanggalLahir.daftarTahun', () {
    test('menurun dari tahun berjalan ke 1970', () {
      final list = TanggalLahir.daftarTahun(2026);
      expect(list.first, 2026);
      expect(list.last, TanggalLahir.awalTahun);
      expect(list.length, 2026 - TanggalLahir.awalTahun + 1);
    });
  });

  group('TanggalLahir input manual', () {
    test('parseTanggal hanya menerima angka', () {
      expect(TanggalLahir.parseTanggal('5'), 5);
      expect(TanggalLahir.parseTanggal(' 17 '), 17);
      expect(TanggalLahir.parseTanggal(''), isNull);
      expect(TanggalLahir.parseTanggal('abc'), isNull);
    });

    test('parseTahun menolak di luar rentang', () {
      expect(TanggalLahir.parseTahun('2000', 2026), 2000);
      expect(TanggalLahir.parseTahun('1969', 2026), isNull);
      expect(TanggalLahir.parseTahun('2027', 2026), isNull);
      expect(TanggalLahir.parseTahun('abcd', 2026), isNull);
    });

    test('errorTanggal sadar batas bulan', () {
      expect(
        TanggalLahir.errorTanggal('31', bulan: 2, tahun: 2001),
        'Maks 28 hari',
      );
      expect(TanggalLahir.errorTanggal('29', bulan: 2, tahun: 2000), isNull);
      expect(TanggalLahir.errorTanggal('', bulan: 1), 'Tanggal wajib diisi');
      expect(TanggalLahir.errorTanggal('0', bulan: 1), 'Tanggal 1-31');
    });

    test('errorTahun memakai rentang yang sama', () {
      expect(TanggalLahir.errorTahun('2000', 2026), isNull);
      expect(TanggalLahir.errorTahun('', 2026), 'Tahun wajib diisi');
      expect(TanggalLahir.errorTahun('1969', 2026), '1970-2026');
    });
  });
}
