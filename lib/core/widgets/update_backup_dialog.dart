import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/services/export_service.dart';

/// Modal rekomendasi backup yang muncul setelah "Update Sekarang" diklik.
///
/// Mengembalikan true bila alur update boleh dilanjutkan (setelah backup
/// tersimpan atau user memilih melewatinya), dan false bila dibatalkan.
Future<bool> showUpdateBackupDialog(BuildContext context) async {
  final lanjut = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => const _UpdateBackupDialog(),
  );
  return lanjut ?? false;
}

class _UpdateBackupDialog extends StatefulWidget {
  const _UpdateBackupDialog();

  @override
  State<_UpdateBackupDialog> createState() => _UpdateBackupDialogState();
}

class _UpdateBackupDialogState extends State<_UpdateBackupDialog> {
  bool _busy = false;

  /// Backup memakai [ExportService.exportSql] yang sudah membuka dialog simpan
  /// native dan membuat dump SQL siap diimpor kembali lewat fitur Import.
  Future<void> _backup() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    String? path;
    try {
      path = await ExportService.exportSql();
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal membuat backup: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!mounted) return;

    if (path == null) {
      setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Backup dibatalkan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Backup tersimpan: ${p.basename(path)}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
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
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.save_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backup Data Dulu?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Simpan salinan database (.sql) ke folder pilihan Anda '
                  'sebelum aplikasi diperbarui.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
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
              onPressed: _busy ? null : () => Navigator.of(context).pop(true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.borderMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Lewati',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _busy ? null : _backup,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Backup Sekarang',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
