import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/services/update_service.dart';

/// Modal progres pembaruan: unduh installer, lalu tawarkan pemasangan.
///
/// Sebelum installer dijalankan koneksi database ditutup lebih dulu supaya
/// berkas di `%APPDATA%` tidak tertinggal dalam keadaan setengah tertulis.
Future<void> showUpdateProgressDialog(
  BuildContext context,
  UpdateCheckResult result,
) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    barrierDismissible: false,
    builder: (_) => _UpdateProgressDialog(result: result),
  );
}

enum _Phase { downloading, ready, error }

class _UpdateProgressDialog extends StatefulWidget {
  const _UpdateProgressDialog({required this.result});

  final UpdateCheckResult result;

  @override
  State<_UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<_UpdateProgressDialog> {
  _Phase _phase = _Phase.downloading;
  File? _file;
  String? _error;
  int _received = 0;
  int _total = 0;
  bool _cancelled = false;
  bool _installing = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  @override
  void dispose() {
    _cancelled = true;
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() {
      _phase = _Phase.downloading;
      _error = null;
    });

    try {
      final file = await UpdateService.download(
        widget.result,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _received = received;
            _total = total;
          });
        },
        isCancelled: () => _cancelled,
      );
      if (!mounted) return;
      setState(() {
        _file = file;
        _phase = _Phase.ready;
      });
    } on UpdateCancelledException {
      // Dialog sudah ditutup pengguna; tidak ada yang perlu ditampilkan.
    } on UpdateException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _phase = _Phase.error;
      });
    }
  }

  Future<void> _install() async {
    final file = _file;
    if (file == null) return;

    setState(() => _installing = true);
    try {
      // Tutup database lebih dulu agar tidak ada berkas WAL yang tertinggal.
      await closeAppDatabaseForUpdate();
      await UpdateService.launchInstaller(file);
      // Beri waktu installer tampil sebelum jendela aplikasi ditutup.
      await Future.delayed(const Duration(milliseconds: 800));
      await windowManager.destroy();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _installing = false;
        _error = '$error';
        _phase = _Phase.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: _buildBody(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final (icon, iconColor, title) = switch (_phase) {
      _Phase.downloading => (
        Icons.arrow_downward_rounded,
        AppColors.primary,
        'Mengunduh Pembaruan',
      ),
      _Phase.ready => (
        Icons.check_circle_rounded,
        AppColors.primary,
        'Pembaruan Siap Dipasang',
      ),
      _Phase.error => (
        Icons.error_outline_rounded,
        Colors.redAccent,
        'Pembaruan Gagal',
      ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _phase == _Phase.error
                  ? Colors.redAccent.withValues(alpha: 0.1)
                  : AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Versi ${widget.result.latestVersion ?? '-'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _Phase.downloading:
        final fraction = _total > 0 ? _received / _total : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 4,
                backgroundColor: AppColors.sectionCardBg,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _progressLabel(fraction),
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
      case _Phase.ready:
        return const Text(
          'Aplikasi akan ditutup agar installer dapat mengganti berkas. '
          'Data Anda di %APPDATA% tidak tersentuh.',
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: AppColors.textMuted,
            fontFamily: 'Inter',
          ),
        );
      case _Phase.error:
        return Text(
          _error ?? 'Terjadi kesalahan yang tidak diketahui.',
          style: const TextStyle(
            fontSize: 13,
            height: 1.45,
            color: AppColors.textDark,
            fontFamily: 'Inter',
          ),
        );
    }
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.sectionLight,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _installing
                  ? null
                  : () {
                      _cancelled = true;
                      Navigator.of(context).pop();
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.borderMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                switch (_phase) {
                  _Phase.downloading => 'Batal',
                  _Phase.ready => 'Nanti',
                  _Phase.error => 'Tutup',
                },
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: switch (_phase) {
                _Phase.downloading => null,
                _Phase.ready => _installing ? null : _install,
                _Phase.error => _installing ? null : _startDownload,
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _installing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      switch (_phase) {
                        _Phase.downloading => 'Mengunduh…',
                        _Phase.ready => 'Pasang Sekarang',
                        _Phase.error => 'Coba Lagi',
                      },
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _progressLabel(double? fraction) {
    if (fraction == null) return 'Menyiapkan unduhan…';
    final percent = (fraction * 100).clamp(0, 100).round();
    return '${_formatMb(_received)} / ${_formatMb(_total)} MB ($percent%)';
  }

  String _formatMb(int bytes) {
    final mb = bytes / (1024 * 1024);
    return mb.toStringAsFixed(1).replaceAll('.', ',');
  }
}
