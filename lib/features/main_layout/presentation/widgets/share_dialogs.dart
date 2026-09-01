import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/services/export_service.dart';
import 'package:eposwa/core/services/import_service.dart';
import 'package:eposwa/core/services/share_service.dart';
import 'package:eposwa/core/widgets/excel_table.dart';

/// Hasil dialog berbagi instan.
class ShareResult {
  /// SQL yang diterima (null jika kita yang mengirim).
  final String? sql;

  /// Nama laptop lawan.
  final String peerName;

  /// true = kita mengirim data, false = kita menerima data.
  final bool sent;

  const ShareResult({this.sql, required this.peerName, required this.sent});
}

enum _SharePhase { waiting, transferring, error }

/// Modal berbagi instan (ala ShareIt):
/// laptop icon + animasi pulse, hotspot info, daftar peer dengan Kirim/Terima.
class ShareDialog extends StatefulWidget {
  const ShareDialog({super.key});

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  _SharePhase _phase = _SharePhase.waiting;
  String _transferLabel = '';
  String _errorMessage = '';
  HotspotInfo? _hotspotInfo;
  bool _hotspotStartedByUs = false;
  bool _busy = false;

  StreamSubscription<SharePeer>? _peersSub;
  StreamSubscription<String>? _receiveSub;

  List<SharePeer> get _peers => ShareService.instance.peerList;

  @override
  void initState() {
    super.initState();
    ShareService.instance.dataProvider = () => ExportService.exportSqlToString();
    _peersSub = ShareService.instance.peers.listen((_) {
      if (mounted) setState(() {});
    });
    _receiveSub = ShareService.instance.onReceiveSql.listen((sql) {
      if (!mounted) return;
      setState(() {
        _phase = _SharePhase.transferring;
        _transferLabel =
            'Menerima data dari ${ShareService.instance.lastSenderName}...';
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        _finish(
          ShareResult(
            sql: sql,
            peerName: ShareService.instance.lastSenderName,
            sent: false,
          ),
        );
      });
    });
    _init();
  }

  Future<void> _init() async {
    try {
      await ShareService.instance.start();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _SharePhase.error;
        _errorMessage = 'Gagal memulai layanan berbagi: $e';
      });
      return;
    }
    if (!mounted) return;
    setState(() {});

    // Jika sudah berada di jaringan hotspot, jangan menyalakan hotspot sendiri.
    final onHotspot = await ShareService.isOnHotspotNetwork();
    if (!mounted || onHotspot) return;
    final info = await ShareService.enableHotspot();
    if (!mounted) return;
    setState(() {
      _hotspotInfo = info;
      _hotspotStartedByUs = info.enabled;
    });
  }

  Future<void> _send(SharePeer peer) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _phase = _SharePhase.transferring;
      _transferLabel = 'Mengirim data ke ${peer.name}...';
    });
    try {
      final sql = await ExportService.exportSqlToString();
      await ShareService.instance.sendSqlTo(peer, sql);
      if (!mounted) return;
      _finish(ShareResult(peerName: peer.name, sent: true));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _phase = _SharePhase.error;
        _errorMessage = 'Gagal mengirim ke ${peer.name}: $e';
      });
    }
  }

  Future<void> _receive(SharePeer peer) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _phase = _SharePhase.transferring;
      _transferLabel = 'Menerima data dari ${peer.name}...';
    });
    try {
      final sql = await ShareService.instance.requestSqlFrom(peer);
      if (!mounted) return;
      _finish(ShareResult(sql: sql, peerName: peer.name, sent: false));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _phase = _SharePhase.error;
        _errorMessage = 'Gagal menerima dari ${peer.name}: $e';
      });
    }
  }

  void _finish(ShareResult? result) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _peersSub?.cancel();
    _receiveSub?.cancel();
    ShareService.instance.dataProvider = null;
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
                  Icons.bolt_rounded,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Berbagi Instan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                if (_phase != _SharePhase.transferring)
                  IconButton(
                    tooltip: 'Tutup',
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => _finish(null),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_phase == _SharePhase.waiting) _buildWaiting(),
            if (_phase == _SharePhase.transferring) _buildTransferring(),
            if (_phase == _SharePhase.error) _buildError(),
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
        const SizedBox(height: 12),
        const Center(child: _PulseLaptop()),
        const SizedBox(height: 16),
        Center(
          child: Text(
            hasPeers ? 'Laptop terdeteksi!' : 'Mencari laptop di jaringan...',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Pastikan kedua laptop terhubung ke hotspot WiFi yang sama',
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
                color: info.enabled ? const Color(0xFF059669) : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                info.enabled ? 'Hotspot aktif' : 'Hotspot',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
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
                color: info.enabled ? AppColors.textMuted : const Color(0xFFEF4444),
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
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  peer.ip,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _send(peer),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 34),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
            ),
            child: const Text('Kirim'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => _receive(peer),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 34),
              textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
            ),
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferring() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Center(child: _PulseLaptop()),
        const SizedBox(height: 16),
        Center(
          child: Text(
            _transferLabel,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
                  _phase = _SharePhase.waiting;
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

/// Icon laptop di tengah dengan animasi pulse (lingkaran denyut + icon berdenyut).
class _PulseLaptop extends StatefulWidget {
  const _PulseLaptop();

  @override
  State<_PulseLaptop> createState() => _PulseLaptopState();
}

class _PulseLaptopState extends State<_PulseLaptop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _ring(double phaseOffset) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final raw = (_controller.value + phaseOffset) % 1.0;
        final scale = 1.0 + raw * 1.1;
        final opacity = (1.0 - raw) * 0.4;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 150 * 0.62,
              height: 150 * 0.62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ring(0.0),
          _ring(0.5),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final scale = 1.0 + 0.07 * (0.5 - (t - 0.5).abs() * 2);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.laptop_mac_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Aksi yang dipilih user pada [PreviewDialog].
enum PreviewAction { apply, saved, cancel }

/// Modal preview isi tabel dari data yang diterima,
/// dengan pilihan Simpan atau Terapkan dalam aplikasi.
class PreviewDialog extends StatefulWidget {
  final String sql;
  final String senderName;

  const PreviewDialog({
    super.key,
    required this.sql,
    required this.senderName,
  });

  @override
  State<PreviewDialog> createState() => _PreviewDialogState();
}

class _PreviewDialogState extends State<PreviewDialog> {
  static const _labels = {
    'admins': 'Admin',
    'pesertas': 'Peserta',
    'skrining_records': 'Skrining',
    'skrining_jawabans': 'Jawaban',
  };

  late final Map<String, List<Map<String, String>>> _tables;
  late final List<String> _order;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tables = ImportService.parseSqlTables(widget.sql);
    _order = _tables.keys.toList();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final defaultName =
          'eposwa_terima_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.sql';
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Data Terkirim',
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['sql'],
      );
      if (!mounted) return;
      if (path == null) {
        setState(() => _saving = false);
        return;
      }
      final file = File(path);
      await file.writeAsString(widget.sql);
      if (!mounted) return;
      Navigator.of(context).pop((PreviewAction.saved, path));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPeserta = _tables['pesertas']!.length;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 780,
        height: 540,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.visibility_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Preview Data Diterima',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () =>
                        Navigator.of(context).pop((PreviewAction.cancel, null)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Data diterima dari ${widget.senderName}: $totalPeserta peserta, ${_tables['skrining_records']!.length} skrining.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: DefaultTabController(
                  length: _order.length,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textMuted,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          for (final t in _order)
                            Tab(text: '${_labels[t] ?? t} (${_tables[t]!.length})'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: TabBarView(
                          children: [for (final t in _order) _buildTable(t)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop((PreviewAction.cancel, null)),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop((PreviewAction.apply, null)),
                    child: const Text('Terapkan dalam Aplikasi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(String table) {
    final rows = _tables[table]!;
    if (rows.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data pada tabel ${_labels[table] ?? table}',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      );
    }
    final headers = rows.first.keys.toList();
    final columns = [
      for (final h in headers)
        ExcelColumn(label: h, flex: h == 'nik' ? 1.5 : 1, sortable: false),
    ];
    final cells = [
      for (final r in rows)
        [
          for (final h in headers)
            Text(r[h] ?? '', style: const TextStyle(fontSize: 12.5)),
        ],
    ];
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: ExcelTable(
          columns: columns,
          rows: cells,
          headerHeight: 40,
          rowHeight: 42,
          wrapColumns: const {0},
        ),
      ),
    );
  }
}