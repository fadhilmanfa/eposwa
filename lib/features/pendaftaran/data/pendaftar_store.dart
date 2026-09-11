/// Penyimpanan pendaftar in-memory yang dipakai bersama
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

  final List<Pendaftar> _pendaftar = [];

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