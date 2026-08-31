/// Data & logika skrining kesehatan jiwa Posyandu Jiwa Digital.
/// Mengikuti aturan pada "Panduan Skrining & Arsitektur Sistem Posyandu Jiwa Digital".
library;

class SkriningPertanyaan {
  final int nomor;
  final String teks;
  final String domain;
  final bool isRedFlag;

  const SkriningPertanyaan({
    required this.nomor,
    required this.teks,
    required this.domain,
    this.isRedFlag = false,
  });
}

const List<SkriningPertanyaan> kSkriningPertanyaan = [
  SkriningPertanyaan(
    nomor: 1,
    teks: 'Apakah Anda sering merasa sedih, murung, atau hampa tanpa alasan yang jelas?',
    domain: 'Depressive Mood',
  ),
  SkriningPertanyaan(
    nomor: 2,
    teks: 'Apakah Anda kehilangan minat atau tidak lagi merasa senang melakukan aktivitas yang biasa Anda nikmati?',
    domain: 'Anhedonia',
  ),
  SkriningPertanyaan(
    nomor: 3,
    teks: 'Apakah Anda mengalami perubahan nafsu makan yang drastis atau penurunan/kenaikan berat badan tanpa disengaja?',
    domain: 'Perubahan Somatik & Metabolik',
  ),
  SkriningPertanyaan(
    nomor: 4,
    teks: 'Apakah Anda mengalami kesulitan tidur, sering terbangun di malam hari, atau justru tidur berlebihan?',
    domain: 'Insomnia / Hipersomnia',
  ),
  SkriningPertanyaan(
    nomor: 5,
    teks: 'Apakah Anda merasa sangat lelah, lemas, atau tidak memiliki energi untuk menyelesaikan aktivitas sehari-hari?',
    domain: 'Fatigue / Energi Rendah',
  ),
  SkriningPertanyaan(
    nomor: 6,
    teks: 'Apakah Anda memiliki kesulitan berkonsentrasi, sering lupa, atau lambat dalam membuat keputusan sederhana?',
    domain: 'Gangguan Kognitif',
  ),
  SkriningPertanyaan(
    nomor: 7,
    teks: 'Apakah Anda merasa diri Anda gagal, tidak berharga, atau sering menyalahkan diri sendiri secara berlebihan?',
    domain: 'Harga Diri Rendah / Perasaan Bersalah',
  ),
  SkriningPertanyaan(
    nomor: 8,
    teks: 'Apakah Anda cenderung menarik diri, enggan berinteraksi, atau malas berhubungan dengan orang lain?',
    domain: 'Penarikan Diri Sosio-Emosional',
  ),
  SkriningPertanyaan(
    nomor: 9,
    teks: 'Apakah Anda sering merasa cemas, gelisah, tegang, atau khawatir berlebihan mengenai berbagai hal?',
    domain: 'Ansietas / Kecemasan',
  ),
  SkriningPertanyaan(
    nomor: 10,
    teks: 'Apakah Anda pernah berpikiran untuk menyakiti diri sendiri, merasa lebih baik mati, atau berencana bunuh diri?',
    domain: 'Ideasi Bunuh Diri / Self-Harm',
    isRedFlag: true,
  ),
];

enum SkriningKategori {
  rendah,
  sedang,
  tinggi,
  kritis,
}

extension SkriningKategoriX on SkriningKategori {
  String get label {
    switch (this) {
      case SkriningKategori.rendah:
        return 'Risiko Rendah';
      case SkriningKategori.sedang:
        return 'Risiko Sedang';
      case SkriningKategori.tinggi:
        return 'Risiko Tinggi';
      case SkriningKategori.kritis:
        return 'KRITIS';
    }
  }
}

/// Hasil perhitungan skrining berdasarkan aturan dokumen:
/// - Q10 "YA" (red flag) -> KRISIS PSIKIATRI, skor Q1-9 diabaikan.
/// - Q10 "TIDAK" -> skor akumulasi "YA" Q1-9:
///   0-2 Risiko Rendah, 3-5 Risiko Sedang, 6-9 Risiko Tinggi.
class SkriningHasil {
  final int skor;
  final SkriningKategori kategori;
  final bool isRedFlag;
  final String rekomendasi;

  const SkriningHasil({
    required this.skor,
    required this.kategori,
    required this.isRedFlag,
    required this.rekomendasi,
  });

  static SkriningHasil hitung(List<bool?> jawaban) {
    final jawabanQ10 = jawaban.length >= 10 ? jawaban[9] : false;

    if (jawabanQ10 == true) {
      return const SkriningHasil(
        skor: 0,
        kategori: SkriningKategori.kritis,
        isRedFlag: true,
        rekomendasi:
            'PERTAHANAN DARURAT: Responden menunjukkan ideasi bunuh diri / self-harm. '
            'Skor kuesioner diabaikan dan status KRISIS PSIKIATRI (CRITICAL_ALERT) ditetapkan. '
            'Segera rujuk ke Perawat Pembina Kesehatan Jiwa Puskesmas / layanan kesehatan terdekat untuk penanganan segera.',
      );
    }

    var skor = 0;
    for (var i = 0; i < 9; i++) {
      if (jawaban.length > i && jawaban[i] == true) {
        skor++;
      }
    }

    final SkriningKategori kategori;
    final String rekomendasi;
    if (skor <= 2) {
      kategori = SkriningKategori.rendah;
      rekomendasi =
          'Berikan materi psikoedukasi mandiri pada aplikasi. '
          'Atur pengingat otomatis untuk skrining ulang pada Posyandu Jiwa bulan berikutnya.';
    } else if (skor <= 5) {
      kategori = SkriningKategori.sedang;
      rekomendasi =
          'Kirimkan data responden ke antrean rujukan Perawat Jiwa Puskesmas (CMHN). '
          'Jadwalkan sesi konseling awal dan kunjungan kader.';
    } else {
      kategori = SkriningKategori.tinggi;
      rekomendasi =
          'Terbitkan surat rujukan elektronik (e-Rujukan) ke Dokter Umum Puskesmas / '
          'Psikolog Klinis / RSJ untuk wawancara diagnostik lanjutan (DSM-5 / PPDGJ-III).';
    }

    return SkriningHasil(
      skor: skor,
      kategori: kategori,
      isRedFlag: false,
      rekomendasi: rekomendasi,
    );
  }
}

/// Catatan hasil skrining pada daftar "Skrining & Penilaian".
class SkriningRecord {
  final String nama;
  final String tanggal;
  final int? skor;
  final SkriningKategori kategori;
  final bool isRedFlag;

  const SkriningRecord({
    required this.nama,
    required this.tanggal,
    required this.kategori,
    this.skor,
    this.isRedFlag = false,
  });

  SkriningRecord.fromHasil({
    required this.nama,
    required this.tanggal,
    required SkriningHasil hasil,
  })  : skor = hasil.skor,
        kategori = hasil.kategori,
        isRedFlag = hasil.isRedFlag;

  String get skorLabel => isRedFlag ? 'RED FLAG' : '${skor ?? 0}';
}