import 'package:eposwa/core/services/export_service.dart';
import 'package:eposwa/core/services/import_service.dart';

/// Hasil satu putaran sinkronisasi dua-arah dengan satu peer.
class SyncOutcome {
  /// Ringkasan perubahan di database lokal akibat SQL dari peer.
  final ImportResult appliedFromPeer;

  /// Jumlah peserta lokal yang dikirim ke peer (isi dump kita).
  final int sentPeserta;

  /// Jumlah skrining lokal yang dikirim ke peer.
  final int sentSkrining;

  /// Jumlah peserta pada SQL yang diterima dari peer.
  final int receivedPeserta;

  const SyncOutcome({
    required this.appliedFromPeer,
    required this.sentPeserta,
    required this.sentSkrining,
    required this.receivedPeserta,
  });
}

/// Sinkronisasi union antar dua laptop: NIK baru ditambah, NIK sama
/// digabung (hanya field kosong yang diisi — tidak ada data yang hilang),
/// skrining didedup sehingga sync berulang idempoten.
///
/// Penanda asal A/B: TIDAK disimpan sebagai kolom. Skema tetap
/// (NIK UNIQUE, tanpa kolom asal) agar merge/export tidak berubah.
/// "Ditandai asalnya" hanya muncul sebagai angka di dialog hasil
/// (X baru dari peer, Y terkirim ke peer) — bukan label per baris.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  /// Terapkan SQL yang diterima dari peer ke database lokal.
  /// Mode union: peserta baru → insert; NIK sama → merge (isi yang kosong).
  Future<ImportResult> applyPeerSql(String peerSql) {
    return ImportService.importSqlFromContent(
      peerSql,
      ImportStrategy.merge,
      dedupeSkrining: true,
    );
  }

  /// Bangun [SyncOutcome] setelah pertukaran selesai.
  Future<SyncOutcome> buildOutcome({
    required String localSql,
    required String peerSql,
    required ImportResult applied,
  }) async {
    int countInserts(String sql, String table) => RegExp(
      'INSERT INTO "$table"',
      caseSensitive: false,
    ).allMatches(sql).length;
    return SyncOutcome(
      appliedFromPeer: applied,
      sentPeserta: countInserts(localSql, 'pesertas'),
      sentSkrining: countInserts(localSql, 'skrining_records'),
      receivedPeserta: countInserts(peerSql, 'pesertas'),
    );
  }

  /// Dump lokal untuk dikirim ke peer.
  Future<String> localDump() => ExportService.exportSqlToString();
}
