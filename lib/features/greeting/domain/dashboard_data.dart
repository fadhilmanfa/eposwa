import 'package:eposwa/core/database/app_database.dart';

import 'aktivitas_harian.dart';
import 'chart_periode.dart';
import 'tanggal_helper.dart';

/// Format angka dengan pemisah ribuan, contoh: 1428 → "1,428".
String formatAngka(int n) => n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );

/// Ringkasan statistik dashboard halaman Greeting, dihitung murni (pure)
/// dari data mentah peserta & skrining yang sudah dimuat repository.
class DashboardData {
  final int pendaftaranHariIni;
  final int sudahScreening;
  final int totalTerdaftar;
  final List<AktivitasHarian> aktivitas;

  const DashboardData({
    required this.pendaftaranHariIni,
    required this.sudahScreening,
    required this.totalTerdaftar,
    required this.aktivitas,
  });

  /// Menghitung seluruh metrik dashboard dari data yang diberikan.
  ///
  /// [now] dapat di-inject untuk keperluan pengujian; default ke waktu sekarang.
  /// Data dengan tanggal tidak valid akan diabaikan tanpa menyebabkan error.
  factory DashboardData.hitung({
    required List<Peserta> pesertas,
    required List<SkriningRecord> skrining,
    required ChartPeriode periode,
    RentangTanggal? customRange,
    DateTime? now,
  }) {
    final reference = TanggalHelper.dateOnly(now ?? DateTime.now());

    return DashboardData(
      pendaftaranHariIni: pesertas
          .where((p) => TanggalHelper.sameDay(p.tglDaftar, reference))
          .length,
      sudahScreening: skrining.map((s) => s.pesertaId).toSet().length,
      totalTerdaftar: pesertas.length,
      aktivitas: _hitungAktivitas(
        pesertas,
        skrining,
        periode,
        customRange,
        reference,
      ),
    );
  }

  static List<AktivitasHarian> _hitungAktivitas(
    List<Peserta> pesertas,
    List<SkriningRecord> skrining,
    ChartPeriode periode,
    RentangTanggal? customRange,
    DateTime reference,
  ) {
    switch (periode) {
      case ChartPeriode.mingguIni:
        return TanggalHelper.hariDalamMinggu(reference).map((day) {
          final interval = IntervalTanggal(day, day, label: day.toString());
          return _bucket(
            interval,
            label: TanggalHelper.singkatHari(day.weekday),
            pesertas: pesertas,
            skrining: skrining,
          );
        }).toList();

      case ChartPeriode.bulanIni:
        return TanggalHelper.mingguDalamBulan(reference).map((week) {
          return _bucket(
            week,
            label: week.label,
            pesertas: pesertas,
            skrining: skrining,
          );
        }).toList();

      case ChartPeriode.tahunIni:
        return TanggalHelper.bulanDalamTahun(reference).map((month) {
          return _bucket(
            month,
            label: month.label,
            pesertas: pesertas,
            skrining: skrining,
          );
        }).toList();

      case ChartPeriode.kustom:
        if (customRange == null) return const [];
        return TanggalHelper.bucketKustom(customRange).map((bucket) {
          return _bucket(
            bucket,
            label: bucket.label,
            pesertas: pesertas,
            skrining: skrining,
          );
        }).toList();
    }
  }

  static AktivitasHarian _bucket(
    IntervalTanggal interval, {
    required String label,
    required List<Peserta> pesertas,
    required List<SkriningRecord> skrining,
  }) {
    return AktivitasHarian(
      label: label,
      pendaftaran: pesertas
          .where((p) => TanggalHelper.dalamInterval(p.tglDaftar, interval))
          .length,
      test: skrining
          .where((s) => TanggalHelper.dalamInterval(s.tanggal, interval))
          .length,
    );
  }
}