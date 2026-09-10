/// Periode tampilan grafik aktivitas harian di dashboard.
enum ChartPeriode { mingguIni, bulanIni, tahunIni, kustom }

extension ChartPeriodeLabel on ChartPeriode {
  String get label => switch (this) {
        ChartPeriode.mingguIni => 'Minggu Ini',
        ChartPeriode.bulanIni => 'Bulan Ini',
        ChartPeriode.tahunIni => 'Tahun Ini',
        ChartPeriode.kustom => 'Kustom',
      };
}