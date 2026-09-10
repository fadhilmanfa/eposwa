/// Rentang tanggal inklusif (misal hasil date-range picker).
class RentangTanggal {
  final DateTime mulai;
  final DateTime selesai;

  const RentangTanggal(this.mulai, this.selesai);
}

/// Rentang interval dengan label untuk dijadikan satu bucket grafik.
class IntervalTanggal {
  final DateTime mulai;
  final DateTime selesai;
  final String label;

  const IntervalTanggal(this.mulai, this.selesai, {required this.label});
}

/// Utilitas tanggal untuk format `dd/MM/yyyy` yang dipakai database lokal.
///
/// Semua fungsi bersifat murni dan toleran terhadap data lama/rusak, sehingga
/// dashboard tetap aman meskipun ada tanggal yang tidak bisa di-parse.
class TanggalHelper {
  TanggalHelper._();

  /// Parse string `dd/MM/yyyy` (toleran `d/M/yyyy`).
  /// Mengembalikan `null` bila format tidak valid.
  static DateTime? parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    final parsed = DateTime(year, month, day);
    // DateTime menormalisasi tanggal overflow (mis. 30/02), jadi pastikan
    // hasilnya benar-benar sama sebelum diterima.
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  /// Format tanggal ke `dd/MM/yyyy`.
  static String format(DateTime t) {
    final day = t.day.toString().padLeft(2, '0');
    final month = t.month.toString().padLeft(2, '0');
    return '$day/$month/${t.year}';
  }

  /// Format singkat `dd/MM` untuk label sumbu grafik.
  static String formatShort(DateTime t) {
    final day = t.day.toString().padLeft(2, '0');
    final month = t.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  /// Normalisasi tanggal ke tengah malam (00:00).
  static DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  /// Senin 00:00 pada minggu yang memuat [t].
  static DateTime startOfWeek(DateTime t) {
    final d = dateOnly(t);
    // DateTime.weekday: Senin = 1 ... Minggu = 7.
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// 7 hari berurutan (Senin–Minggu) pada minggu yang memuat [now].
  static List<DateTime> hariDalamMinggu(DateTime now) {
    final start = startOfWeek(now);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  /// Rentang minggu (mulai Senin) yang beririsan dengan bulan [now],
  /// dibatasi ke dalam bulan. Label: "Minggu 1", "Minggu 2", dst.
  static List<IntervalTanggal> mingguDalamBulan(DateTime now) {
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final weeks = <IntervalTanggal>[];
    var start = startOfWeek(monthStart);
    var index = 1;
    while (true) {
      final rawEnd = start.add(const Duration(days: 6));
      final effectiveStart = start.isBefore(monthStart) ? monthStart : start;
      final effectiveEnd = rawEnd.isAfter(monthEnd) ? monthEnd : rawEnd;
      weeks.add(
        IntervalTanggal(
          effectiveStart,
          effectiveEnd,
          label: 'Minggu $index',
        ),
      );
      if (!rawEnd.isBefore(monthEnd)) break;
      start = rawEnd.add(const Duration(days: 1));
      index++;
    }
    return weeks;
  }

  /// Rentang per bulan (Januari–Desember) pada tahun [now].
  static List<IntervalTanggal> bulanDalamTahun(DateTime now) {
    return List.generate(12, (i) {
      final start = DateTime(now.year, i + 1);
      final end = DateTime(now.year, i + 2, 0);
      return IntervalTanggal(
        start,
        end,
        label: singkatBulan(i + 1),
      );
    });
  }

  /// Bucket untuk rentang kustom dengan granularitas yang menyesuaikan lebar
  /// rentang: ≤ 7 hari per hari, ≤ 12 minggu per minggu, sisanya per bulan.
  static List<IntervalTanggal> bucketKustom(RentangTanggal range) {
    final mulai = dateOnly(range.mulai);
    final selesai = dateOnly(range.selesai);
    final totalDays = selesai.difference(mulai).inDays + 1;

    if (totalDays <= 7) {
      return List.generate(
        totalDays,
        (i) {
          final day = mulai.add(Duration(days: i));
          return IntervalTanggal(day, day, label: formatShort(day));
        },
        growable: false,
      );
    }

    if (totalDays <= 84) {
      final weeks = <IntervalTanggal>[];
      var start = startOfWeek(mulai);
      var weekNumber = 1;
      while (!start.isAfter(selesai)) {
        final rawEnd = start.add(const Duration(days: 6));
        final effectiveStart = start.isBefore(mulai) ? mulai : start;
        final effectiveEnd = rawEnd.isAfter(selesai) ? selesai : rawEnd;
        weeks.add(
          IntervalTanggal(
            effectiveStart,
            effectiveEnd,
            label: 'Minggu $weekNumber',
          ),
        );
        if (!rawEnd.isBefore(selesai)) break;
        start = rawEnd.add(const Duration(days: 1));
        weekNumber++;
      }
      return weeks;
    }

    final months = <IntervalTanggal>[];
    var month = DateTime(mulai.year, mulai.month);
    while (!month.isAfter(selesai)) {
      final rawEnd = DateTime(month.year, month.month + 1, 0);
      final effectiveStart = month.isBefore(mulai) ? mulai : month;
      final effectiveEnd = rawEnd.isAfter(selesai) ? selesai : rawEnd;
      months.add(
        IntervalTanggal(
          effectiveStart,
          effectiveEnd,
          label: singkatBulan(month.month),
        ),
      );
      if (!rawEnd.isBefore(selesai)) break;
      month = DateTime(month.year, month.month + 1);
    }
    return months;
  }

  static String singkatHari(int weekday) => switch (weekday) {
        1 => 'Sen',
        2 => 'Sel',
        3 => 'Rab',
        4 => 'Kam',
        5 => 'Jum',
        6 => 'Sab',
        _ => 'Min',
      };

  static String singkatBulan(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return names[month - 1];
  }

  /// Apakah string tanggal [value] sama dengan hari [day].
  static bool sameDay(String? value, DateTime day) {
    final parsed = parse(value);
    return parsed != null && dateOnly(parsed) == day;
  }

  /// Apakah string tanggal [value] berada dalam rentang inklusif [interval].
  static bool dalamInterval(String? value, IntervalTanggal interval) {
    final parsed = parse(value);
    if (parsed == null) return false;
    final day = dateOnly(parsed);
    return !day.isBefore(interval.mulai) && !day.isAfter(interval.selesai);
  }
}