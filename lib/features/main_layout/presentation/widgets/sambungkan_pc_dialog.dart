import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/services/share_service.dart';
import 'package:eposwa/core/services/sync_service.dart';

/// Hasil dialog Sambungkan PC: ringkasan union sesudah satu putaran
/// sinkronisasi dua-arah dengan satu peer.
class SambungkanPcResult {
  /// Nama laptop lawan.
  final String peerName;

  /// Ringkasan union sisi lokal.
  final SyncOutcome outcome;

  const SambungkanPcResult({required this.peerName, required this.outcome});
}

enum _SyncPhase { waiting, syncing, done, error }

/// Dialog "Sambungkan PC": hotspot info + daftar laptop + satu tombol
/// "Sinkronkan" per peer. Satu tap menukar dump dua arah (opcode 0x03);
/// kedua laptop menerapkan union-merge sehingga berakhir identik.
///
/// Kebijakan data A/B (dipilih: langsung digabung):
/// - Tidak ada pemisahan database dan tidak ada kolom asal.
/// - NIK baru dari peer ditambahkan; NIK sama digabung (hanya field kosong
///   yang diisi); skrining sama tidak digandakan (idempoten).
/// - Asal hanya tampil sebagai angka ringkasan di layar hasil, bukan label
///   per baris.
class SambungkanPcDialog extends StatefulWidget {
  const SambungkanPcDialog({super.key});

  @override
  State<SambungkanPcDialog> createState() => _SambungkanPcDialogState();
}

class _SambungkanPcDialogState extends State<SambungkanPcDialog> {
  _SyncPhase _phase = _SyncPhase.waiting;
  String _statusLabel = '';
  String _errorMessage = '';
  HotspotInfo? _hotspotInfo;
  bool _hotspotStartedByUs = false;
  bool _busy = false;
  SyncOutcome? _lastOutcome;
  String _lastPeerName = '';

  StreamSubscription<SharePeer>? _peersSub;
  StreamSubscription<String>? _syncSub;

  List<SharePeer> get _peers => ShareService.instance.peerList;

  @override
  void initState() {
    super.initState();
    ShareService.instance.dataProvider =
        () => SyncService.instance.localDump();
    // Server-side: peer meminta sinkron → terapkan dump-nya (union),
    // lalu kembalikan dump lokal (sesudah merge) agar peer mendapat union.
    ShareService.instance.syncRequestHandler = (peerSql) async {
      await SyncService.instance.applyPeerSql(peerSql);
      return SyncService.instance.localDump();
    };
    _peersSub = ShareService.instance.peers.listen((_) {
      if (mounted) setState(() {});
    });
    // Sisi yang ditekan tombolnya juga bisa menerima sync dari arah
    // berlawanan; cukup segarkan daftar, tidak perlu aksi khusus.
    _syncSub = ShareService.instance.onSyncRequest.listen((_) {
      if (mounted) setState(() {});
    });
    _init();
  }

  Future<void> _init() async {
    try {
      await ShareService.instance.start();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _SyncPhase.error;
        _errorMessage = 'Gagal memulai layanan berbagi: $e';
      });
      return;
    }
    if (!mounted) return;
    setState(() {});

    final onHotspot = await ShareService.isOnHotspotNetwork();
    if (!mounted || onHotspot) return;
    final info = await ShareService.enableHotspot();
    if (!mounted) return;
    setState(() {
      _hotspotInfo = info;
      _hotspotStartedByUs = info.enabled;
    });
  }

  /// Satu-tap sinkronisasi dua-arah dengan [peer].
  Future<void> _sync(SharePeer peer) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _phase = _SyncPhase.syncing;
      _statusLabel = 'Menyinkronkan dengan ${peer.name}...';
      _errorMessage = '';
    });
    try {
      final localSql = await SyncService.instance.localDump();
      final peerSql = await ShareService.instance.syncWithPeer(
        peer,
        localSql,
      );
      final applied = await SyncService.instance.applyPeerSql(peerSql);
      final outcome = await SyncService.instance.buildOutcome(
        localSql: localSql,
        peerSql: peerSql,
        applied: applied,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _phase = _SyncPhase.done;
        _lastOutcome = outcome;
        _lastPeerName = peer.name;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _phase = _SyncPhase.error;
        _errorMessage = 'Gagal menyinkronkan dengan ${peer.name}: $e';
      });
    }
  }

  void _finish(SambungkanPcResult? result) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  void _closeWithResult() {
    final outcome = _lastOutcome;
    if (outcome == null) {
      _finish(null);
      return;
    }
    _finish(SambungkanPcResult(peerName: _lastPeerName, outcome: outcome));
  }

  @override
  void dispose() {
    _peersSub?.cancel();
    _syncSub?.cancel();
    ShareService.instance.dataProvider = null;
    ShareService.instance.syncRequestHandler = null;
    unawaited(ShareService.instance.stop());
    if (_hotspotStartedByUs) {
      unawaited(ShareService.disableHotspot());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 470,
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.laptop_mac_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Sambungkan PC',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                if (_phase != _SyncPhase.syncing)
                  IconButton(
                    tooltip: 'Tutup',
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => _phase == _SyncPhase.done
                        ? _closeWithResult()
                        : _finish(null),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_phase == _SyncPhase.waiting) _buildWaiting(),
            if (_phase == _SyncPhase.syncing) _buildSyncing(),
            if (_phase == _SyncPhase.done) _buildDone(),
            if (_phase == _SyncPhase.error) _buildError(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaiting() {
    final hasPeers = _peers.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Center(
          child: Text(
            hasPeers ? 'Laptop terdeteksi!' : 'Mencari laptop di jaringan...',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Satu tap Sinkronkan → kedua laptop saling melengkapi (union)',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ),
        if (_hotspotInfo != null) ...[
          const SizedBox(height: 14),
          _hotspotCard(_hotspotInfo!),
        ],
        if (hasPeers) ...[
          const SizedBox(height: 14),
          ..._peers.map(_peerCard),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _hotspotCard(HotspotInfo info) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi_tethering_rounded,
                color: info.enabled
                    ? const Color(0xFF059669)
                    : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                info.enabled ? 'Hotspot aktif' : 'Hotspot',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              const Spacer(),
              if (info.enabled)
                Text(
                  'Laptop lain konek ke WiFi ini',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
            ],
          ),
          if (info.ssid.isNotEmpty) ...[
            const SizedBox(height: 10),
            _credRow('SSID', info.ssid),
            if (info.passphrase != null) ...[
              const SizedBox(height: 6),
              _credRow('Password', info.passphrase!),
            ],
          ],
          if (info.error != null) ...[
            const SizedBox(height: 8),
            Text(
              info.error!,
              style: TextStyle(
                fontSize: 12,
                color: info.enabled
                    ? AppColors.textMuted
                    : const Color(0xFFEF4444),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _credRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Salin $label',
          icon: const Icon(Icons.copy_rounded, size: 16),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
          },
        ),
      ],
    );
  }

  Widget _peerCard(SharePeer peer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primaryPastel,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.laptop_mac_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  peer.ip,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _busy ? null : () => _sync(peer),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 34),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            icon: const Icon(Icons.sync_rounded, size: 16),
            label: const Text('Sinkronkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncing() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Center(
          child: Text(
            _statusLabel,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Menukar data dua arah, lalu menggabungkan...',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 18),
        const LinearProgressIndicator(
          minHeight: 4,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildDone() {
    final outcome = _lastOutcome!;
    final applied = outcome.appliedFromPeer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Icon(
          Icons.check_circle_rounded,
          size: 48,
          color: Color(0xFF059669),
        ),
        const SizedBox(height: 12),
        Text(
          'Sinkron dengan $_lastPeerName selesai',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Kedua laptop kini memiliki gabungan (union) data yang sama.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        _resultRow(
          'Baru dari $_lastPeerName',
          '${applied.imported} peserta, ${applied.skriningAdded} skrining',
        ),
        _resultRow(
          'Digabung (NIK sama)',
          '${applied.merged} peserta, ${applied.skriningSkipped} skrining sudah ada',
        ),
        _resultRow(
          'Terkirim ke $_lastPeerName',
          '${outcome.sentPeserta} peserta, ${outcome.sentSkrining} skrining',
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
              onPressed: _closeWithResult,
              child: const Text('Selesai'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: Color(0xFFEF4444),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => _finish(null),
              child: const Text('Tutup'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                setState(() {
                  _phase = _SyncPhase.waiting;
                  _errorMessage = '';
                });
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ],
    );
  }
}
