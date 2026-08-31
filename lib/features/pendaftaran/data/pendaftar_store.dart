/// Penyimpanan pendaftar in-memory (FE dummy) yang dipakai bersama
/// oleh form pendaftaran, daftar database, dan skrining.
library;

class Pendaftar {
  final String nama;
  final String nik;
  final String program;

  const Pendaftar({
    required this.nama,
    required this.nik,
    required this.program,
  });
}

class PendaftarStore {
  PendaftarStore._();

  static final PendaftarStore instance = PendaftarStore._();

  final List<Pendaftar> _pendaftar = [
    const Pendaftar(
      nama: 'Ahmad Fauzi',
      nik: '3201984712040001',
      program: 'Regular Pagi',
    ),
    const Pendaftar(
      nama: 'Siti Aminah',
      nik: '3201984712040002',
      program: 'Regular Pagi',
    ),
    const Pendaftar(
      nama: 'Budi Santoso',
      nik: '3201984712040003',
      program: 'Eksekutif',
    ),
    const Pendaftar(
      nama: 'Dina Mariana',
      nik: '3201984712040004',
      program: 'Regular Sore',
    ),
    const Pendaftar(
      nama: 'Eko Prasetyo',
      nik: '3201984712040005',
      program: 'Regular Pagi',
    ),
  ];

  List<Pendaftar> get all => List.unmodifiable(_pendaftar);

  void add(Pendaftar pendaftar) {
    if (findByName(pendaftar.nama) != null) return;
    _pendaftar.add(pendaftar);
  }

  void remove(Pendaftar pendaftar) {
    _pendaftar.remove(pendaftar);
  }

  Pendaftar? findByName(String nama) {
    final query = nama.trim().toLowerCase();
    if (query.isEmpty) return null;
    for (final p in _pendaftar) {
      if (p.nama.toLowerCase() == query) return p;
    }
    return null;
  }
}