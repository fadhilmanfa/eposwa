import 'package:flutter_test/flutter_test.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/features/greeting/domain/chart_periode.dart';
import 'package:eposwa/features/greeting/domain/dashboard_data.dart';
import 'package:eposwa/features/greeting/domain/tanggal_helper.dart';

// Referensi waktu: Sabtu, 5 September 2026.
// Minggu berjalan: Senin 31/08/2026 - Minggu 06/09/2026.
final _now = DateTime(2026, 9, 5);

Peserta _peserta({
  int id = 1,
  String? tglDaftar,
}) =>
    Peserta(
      id: id,
      kodePeserta: 'REG-2026-${id.toString().padLeft(3, '0')}',
      nama: 'Peserta $id',
      nik: '320000000000000$id',
      jenisKelamin: 'Laki-laki',
      noHp: '08100000000$id',
      program: '-',
      status: 'Terdaftar',
      tglDaftar: tglDaftar ?? '05/09/2026',
      createdAt: DateTime(2026, 9, 5),
      updatedAt: DateTime(2026, 9, 5),
    );

SkriningRecord _skrining({
  int id = 1,
  int pesertaId = 1,
  String? tanggal,
}) =>
    SkriningRecord(
      id: id,
      pesertaId: pesertaId,
      tanggal: tanggal ?? '05/09/2026',
      skor: 2,
      kategori: 'rendah',
      isRedFlag: false,
      rekomendasi: 'Rekomendasi',
      createdAt: DateTime(2026, 9, 5),
      updatedAt: DateTime(2026, 9, 5),
    );

void main() {
  group('TanggalHelper.parse/format', () {
    test('parse dd/MM/yyyy dan d/M/yyyy yang valid', () {
      expect(TanggalHelper.parse('05/09/2026'), DateTime(2026, 9, 5));
      expect(TanggalHelper.parse('5/9/2026'), DateTime(2026, 9, 5));
    });

    test('parse menolak format yang tidak valid', () {
      expect(TanggalHelper.parse(null), isNull);
      expect(TanggalHelper.parse(''), isNull);
      expect(TanggalHelper.parse('garbage'), isNull);
      expect(TanggalHelper.parse('2026-09-05'), isNull);
      expect(TanggalHelper.parse('30/02/2026'), isNull); // tanggal overflow
    });

    test('format mengembalikan dd/MM/yyyy', () {
      expect(TanggalHelper.format(DateTime(2026, 9, 5)), '05/09/2026');
      expect(TanggalHelper.formatShort(DateTime(2026, 9, 5)), '05/09');
    });

    test('dateOnly menghilangkan komponen waktu', () {
      expect(
        TanggalHelper.dateOnly(DateTime(2026, 9, 5, 14, 30)),
        DateTime(2026, 9, 5),
      );
    });
  });

  group('TanggalHelper.range', () {
    test('startOfWeek mulai dari Senin', () {
      // Sabtu 05/09/2026 -> Senin 31/08/2026
      expect(TanggalHelper.startOfWeek(_now), DateTime(2026, 8, 31));
      // Senin 31/08/2026 -> tetap 31/08/2026
      expect(
        TanggalHelper.startOfWeek(DateTime(2026, 8, 31)),
        DateTime(2026, 8, 31),
      );
    });

    test('hariDalamMinggu menghasilkan 7 hari Senin-Minggu', () {
      final days = TanggalHelper.hariDalamMinggu(_now);
      expect(days.length, 7);
      expect(days.first, DateTime(2026, 8, 31));
      expect(days.last, DateTime(2026, 9, 6));
    });

    test('mingguDalamBulan September 2026 = 5 minggu, terpotong ke bulan', () {
      final weeks = TanggalHelper.mingguDalamBulan(_now);
      expect(weeks.length, 5);
      expect(weeks.map((w) => w.label).toList(),
          ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4', 'Minggu 5']);
      expect(weeks.first.mulai, DateTime(2026, 9, 1));
      expect(weeks.last.selesai, DateTime(2026, 9, 30));
    });

    test('bulanDalamTahun menghasilkan 12 bulan', () {
      final months = TanggalHelper.bulanDalamTahun(_now);
      expect(months.length, 12);
      expect(months.first.label, 'Jan');
      expect(months.last.label, 'Des');
      expect(months.first.mulai, DateTime(2026, 1, 1));
      expect(months.last.selesai, DateTime(2026, 12, 31));
    });

    test('bucketKustom <= 7 hari dikelompokkan per hari', () {
      final buckets = TanggalHelper.bucketKustom(
        RentangTanggal(DateTime(2026, 8, 30), DateTime(2026, 9, 5)),
      );
      expect(buckets.length, 7);
      expect(buckets.first.label, '30/08');
      expect(buckets.last.label, '05/09');
    });

    test('bucketKustom <= 12 minggu dikelompokkan per minggu', () {
      final buckets = TanggalHelper.bucketKustom(
        RentangTanggal(DateTime(2026, 8, 1), DateTime(2026, 8, 31)),
      );
      expect(buckets.length, 6);
      expect(buckets.first.mulai, DateTime(2026, 8, 1)); // potong hari di Agustus
      expect(buckets.last.selesai, DateTime(2026, 8, 31));
      expect(buckets.first.label, 'Minggu 1');
    });

    test('bucketKustom lebih dari 12 minggu dikelompokkan per bulan', () {
      final buckets = TanggalHelper.bucketKustom(
        RentangTanggal(DateTime(2026, 1, 1), DateTime(2026, 12, 31)),
      );
      expect(buckets.length, 12);
      expect(buckets.first.label, 'Jan');
      expect(buckets.last.label, 'Des');
    });
  });

  group('samaTanggal / dalamInterval', () {
    test('sameDay hanya benar pada tanggal yang sama', () {
      expect(TanggalHelper.sameDay('05/09/2026', DateTime(2026, 9, 5)), isTrue);
      expect(
        TanggalHelper.sameDay('05/09/2026', DateTime(2026, 9, 4)),
        isFalse,
      );
      expect(TanggalHelper.sameDay('rusak', DateTime(2026, 9, 5)), isFalse);
    });

    test('dalamInterval inklusif di kedua ujung', () {
      final interval =
          IntervalTanggal(DateTime(2026, 9, 1), DateTime(2026, 9, 7),
              label: 'x');
      expect(TanggalHelper.dalamInterval('01/09/2026', interval), isTrue);
      expect(TanggalHelper.dalamInterval('07/09/2026', interval), isTrue);
      expect(TanggalHelper.dalamInterval('31/08/2026', interval), isFalse);
      expect(TanggalHelper.dalamInterval('08/09/2026', interval), isFalse);
    });
  });

  group('formatAngka', () {
    test('memisahkan ribuan dengan koma', () {
      expect(formatAngka(0), '0');
      expect(formatAngka(5), '5');
      expect(formatAngka(999), '999');
      expect(formatAngka(1000), '1,000');
      expect(formatAngka(1428), '1,428');
      expect(formatAngka(1234567), '1,234,567');
    });
  });

  group('DashboardData.hitung - Minggu Ini', () {
    test('data kosong -> semua nol dan 7 bucket', () {
      final data = DashboardData.hitung(
        pesertas: const [],
        skrining: const [],
        periode: ChartPeriode.mingguIni,
        now: _now,
      );
      expect(data.pendaftaranHariIni, 0);
      expect(data.sudahScreening, 0);
      expect(data.totalTerdaftar, 0);
      expect(data.aktivitas.length, 7);
      expect(
        data.aktivitas.map((a) => a.pendaftaran + a.test).reduce((a, b) => a + b),
        0,
      );
    });

    test('metrik & bucket harian sesuai tanggal data', () {
      final data = DashboardData.hitung(
        pesertas: [
          _peserta(id: 1, tglDaftar: '05/09/2026'), // hari ini
          _peserta(id: 2, tglDaftar: '05/09/2026'), // hari ini
          _peserta(id: 3, tglDaftar: '01/09/2026'), // Selasa pekan ini
        ],
        skrining: [
          _skrining(id: 1, pesertaId: 1, tanggal: '01/09/2026'),
          _skrining(id: 2, pesertaId: 1, tanggal: '02/09/2026'),
          _skrining(id: 3, pesertaId: 2, tanggal: '03/09/2026'),
        ],
        periode: ChartPeriode.mingguIni,
        now: _now,
      );

      expect(data.pendaftaranHariIni, 2);
      expect(data.totalTerdaftar, 3);
      // 2 skrining peserta 1 + 1 skrining peserta 2 -> 2 peserta unik.
      expect(data.sudahScreening, 2);

      expect(
        data.aktivitas.map((a) => a.label).toList(),
        ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
      );
      // Selasa (index 1): 1 pendaftaran (peserta 3), 1 skrining.
      expect(data.aktivitas[1].pendaftaran, 1);
      expect(data.aktivitas[1].test, 1);
      // Rabu (index 2): 1 skrining.
      expect(data.aktivitas[2].test, 1);
      // Sabtu (index 5): 2 pendaftaran, 0 skrining.
      expect(data.aktivitas[5].pendaftaran, 2);
      expect(data.aktivitas[5].test, 0);
    });

    test('tanggal rusak tidak membuat hitungan crash', () {
      final data = DashboardData.hitung(
        pesertas: [
          _peserta(id: 1, tglDaftar: 'tidak-valid'),
          _peserta(id: 2, tglDaftar: '30/02/2026'),
          _peserta(id: 3, tglDaftar: '05/09/2026'),
        ],
        skrining: [_skrining(id: 1, pesertaId: 1, tanggal: 'abc')],
        periode: ChartPeriode.mingguIni,
        now: _now,
      );
      expect(data.totalTerdaftar, 3);
      expect(data.pendaftaranHariIni, 1); // hanya yang valid
      expect(data.sudahScreening, 1);
      expect(data.aktivitas.length, 7);
    });
  });

  group('DashboardData.hitung - periode lain', () {
    test('Bulan Ini: total pendaftaran semua bucket = jumlah peserta', () {
      final data = DashboardData.hitung(
        pesertas: [
          _peserta(id: 1, tglDaftar: '05/09/2026'),
          _peserta(id: 2, tglDaftar: '12/09/2026'),
        ],
        skrining: [_skrining(id: 1, pesertaId: 1, tanggal: '05/09/2026')],
        periode: ChartPeriode.bulanIni,
        now: _now,
      );
      expect(
        data.aktivitas.map((a) => a.label).toList(),
        ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4', 'Minggu 5'],
      );
      expect(data.aktivitas[0].pendaftaran, 1);
      expect(data.aktivitas[1].pendaftaran, 1);
      final totalPendaftaran =
          data.aktivitas.fold(0, (sum, a) => sum + a.pendaftaran);
      expect(totalPendaftaran, 2);
    });

    test('Tahun Ini: 12 bucket bulanan', () {
      final data = DashboardData.hitung(
        pesertas: [_peserta(id: 1, tglDaftar: '05/09/2026')],
        skrining: const [],
        periode: ChartPeriode.tahunIni,
        now: _now,
      );
      expect(data.aktivitas.length, 12);
      expect(data.aktivitas[8].label, 'Sep');
      expect(data.aktivitas[8].pendaftaran, 1);
      expect(data.aktivitas[0].pendaftaran, 0);
    });

    test('Kustom tanpa rentang terpilih -> aktivitas kosong', () {
      final data = DashboardData.hitung(
        pesertas: const [],
        skrining: const [],
        periode: ChartPeriode.kustom,
        customRange: null,
        now: _now,
      );
      expect(data.aktivitas, isEmpty);
    });

    test('Kustom 7 hari: bucket per hari sesuai rentang', () {
      final data = DashboardData.hitung(
        pesertas: [_peserta(id: 1, tglDaftar: '01/09/2026')],
        skrining: const [],
        periode: ChartPeriode.kustom,
        customRange:
            RentangTanggal(DateTime(2026, 8, 30), DateTime(2026, 9, 5)),
        now: _now,
      );
      expect(data.aktivitas.length, 7);
      expect(data.aktivitas[2].label, '01/09');
      expect(data.aktivitas[2].pendaftaran, 1);
    });
  });
}