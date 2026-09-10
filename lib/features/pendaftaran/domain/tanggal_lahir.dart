/// Logika murni untuk input tanggal lahir terpisah (tanggal/bulan/tahun).
///
/// Bebas dari Flutter & database sehingga mudah di-unit-test.
class TanggalLahir {
  TanggalLahir._();

  static const int awalTahun = 1970;

  static const List<String> namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Daftar tahun lahir menurun (tahun berjalan → [awalTahun]).
  static List<int> daftarTahun([int? tahunAkhir]) {
    final akhir = tahunAkhir ?? DateTime.now().year;
    if (akhir < awalTahun) return const [];
    return List.generate(akhir - awalTahun + 1, (i) => akhir - i);
  }

  /// Jumlah hari dalam [bulan] (1-12) pada [tahun].
  static int jumlahHari(int tahun, int bulan) {
    return DateTime(tahun, bulan + 1, 0).day;
  }

  /// Batas hari valid untuk kombinasi [bulan]/[tahun] yang dipilih.
  /// Jika bulan belum dipilih, kembalikan 31.
  static int maxHari({required int? bulan, int? tahun}) {
    if (bulan == null) return 31;
    final y = tahun ?? DateTime.now().year;
    return jumlahHari(y, bulan);
  }

  /// Batas tahun tertua yang diterima untuk input manual.
  static int tahunMaks([int? tahunAkhir]) => tahunAkhir ?? DateTime.now().year;

  /// Parse input tanggal manual (ketik angka). `null` bila kosong/bukan angka.
  static int? parseTanggal(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return int.tryParse(raw.trim());
  }

  /// Parse input tahun manual (ketik angka 4 digit). `null` bila tidak valid.
  static int? parseTahun(String? raw, [int? tahunAkhir]) {
    if (raw == null || raw.trim().isEmpty) return null;
    final tahun = int.tryParse(raw.trim());
    if (tahun == null) return null;
    if (!tahunValid(tahun, tahunAkhir)) return null;
    return tahun;
  }

  /// Tanggal valid bila 1..[maxHari] untuk kombinasi bulan/tahun terpilih.
  static bool tanggalValid(int tanggal, {int? bulan, int? tahun}) {
    if (tanggal < 1) return false;
    return tanggal <= maxHari(bulan: bulan, tahun: tahun);
  }

  /// Tahun valid bila dalam rentang [awalTahun]..tahun berjalan.
  static bool tahunValid(int tahun, [int? tahunAkhir]) {
    return tahun >= awalTahun && tahun <= tahunMaks(tahunAkhir);
  }

  /// Pesan error untuk field tanggal manual, `null` bila valid.
  /// Dipakai sebagai `validator` TextFormField agar gaya error sama
  /// dengan field lain di form pendaftaran.
  static String? errorTanggal(String? raw, {int? bulan, int? tahun}) {
    if (raw == null || raw.trim().isEmpty) return 'Tanggal wajib diisi';
    final tanggal = int.tryParse(raw.trim());
    if (tanggal == null || tanggal < 1 || tanggal > 31) {
      return 'Tanggal 1-31';
    }
    final max = maxHari(bulan: bulan, tahun: tahun);
    if (tanggal > max) return 'Maks $max hari';
    return null;
  }

  /// Pesan error untuk field tahun manual, `null` bila valid.
  static String? errorTahun(String? raw, [int? tahunAkhir]) {
    if (raw == null || raw.trim().isEmpty) return 'Tahun wajib diisi';
    final tahun = int.tryParse(raw.trim());
    final maks = tahunMaks(tahunAkhir);
    if (tahun == null || tahun < awalTahun || tahun > maks) {
      return '$awalTahun-$maks';
    }
    return null;
  }

  /// Format `DD/MM/YYYY`, atau `null` bila belum lengkap.
  static String? format(int? tanggal, int? bulan, int? tahun) {
    if (tanggal == null || bulan == null || tahun == null) return null;
    return '${tanggal.toString().padLeft(2, '0')}/'
        '${bulan.toString().padLeft(2, '0')}/$tahun';
  }

  /// Tanggal perlu dijepit (clamp) bila hari melebihi batas bulan/tahun baru.
  /// Mengembalikan hari yang sudah aman.
  static int? jepitTanggal(int? tanggal, {int? bulan, int? tahun}) {
    if (tanggal == null) return null;
    final max = maxHari(bulan: bulan, tahun: tahun);
    if (tanggal > max) return max;
    return tanggal;
  }
}
