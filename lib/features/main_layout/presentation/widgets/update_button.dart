import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/services/update_service.dart';
import 'package:eposwa/core/widgets/update_backup_dialog.dart';
import 'package:eposwa/core/widgets/update_progress_dialog.dart';

enum _Status { checking, available, upToDate, error }

/// Tombol pembaruan di header: memeriksa rilis GitHub dan menawarkan update.
///
/// Pemeriksaan pertama berjalan senyap saat widget dipasang; klik pada tombol
/// hanya menampilkan popup non-modal berisi hasilnya.
class UpdateButton extends StatefulWidget {
  const UpdateButton({super.key});

  @override
  State<UpdateButton> createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<UpdateButton> {
  final MenuController _controller = MenuController();

  _Status _status = _Status.checking;
  UpdateCheckResult? _result;

  static const _menuStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(8),
    shadowColor: WidgetStatePropertyAll(Color(0x1E000000)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.borderLight),
      ),
    ),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
  );

  @override
  void initState() {
    super.initState();
    final cached = UpdateService.lastResult;
    if (cached != null) {
      _apply(cached);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _apply(UpdateCheckResult result) {
    _result = result;
    _status = result.error != null
        ? _Status.error
        : (result.hasUpdate ? _Status.available : _Status.upToDate);
  }

  Future<void> _check() async {
    if (mounted) {
      setState(() => _status = _Status.checking);
    }
    final result = await UpdateService.check();
    if (!mounted) return;
    setState(() => _apply(result));
  }

  Future<void> _startUpdate() async {
    final result = _result;
    if (result == null || !result.canInstall) return;

    _controller.close();
    final lanjut = await showUpdateBackupDialog(context);
    if (!lanjut || !mounted) return;

    await showUpdateProgressDialog(context, result);
    if (!mounted) return;
    // Dialog ditutup tanpa memasang (mis. memilih "Nanti") — segarkan status.
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      style: _menuStyle,
      alignmentOffset: const Offset(0, 8),
      menuChildren: [_buildPopup()],
      builder: (context, controller, child) {
        final isOpen = controller.isOpen;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => isOpen ? controller.close() : controller.open(),
          hoverColor: AppColors.primary.withValues(alpha: 0.08),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isOpen
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isOpen ? AppColors.primary : AppColors.borderMedium,
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Saat sudah terbaru, tombol cukup menampilkan centang.
                if (_status == _Status.upToDate)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.primary,
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_upward_rounded,
                        size: 17,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                if (_status == _Status.available)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopup() {
    final result = _result;
    final notes = result?.notes;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _status == _Status.error
                  ? Colors.redAccent.withValues(alpha: 0.1)
                  : AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(_popupIcon, color: _popupIconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            _popupTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _popupSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: AppColors.textMuted,
              fontFamily: 'Inter',
            ),
          ),
          if (_status == _Status.available &&
              notes != null &&
              notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              notes,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textMuted,
                fontFamily: 'Inter',
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: _buildAction()),
        ],
      ),
    );
  }

  Widget _buildAction() {
    final style = FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    if (_status == _Status.checking) {
      return FilledButton(
        onPressed: null,
        style: style,
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      );
    }

    return FilledButton(
      onPressed: _status == _Status.available ? _startUpdate : _check,
      style: style,
      child: Text(
        switch (_status) {
          _Status.available => 'Update Sekarang',
          _Status.upToDate => 'Periksa Lagi',
          _ => 'Coba Lagi',
        },
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  IconData get _popupIcon => switch (_status) {
    _Status.checking => Icons.sync_rounded,
    _Status.available => Icons.arrow_upward_rounded,
    _Status.upToDate => Icons.check_rounded,
    _Status.error => Icons.error_outline_rounded,
  };

  Color get _popupIconColor =>
      _status == _Status.error ? Colors.redAccent : AppColors.primary;

  String get _popupTitle => switch (_status) {
    _Status.checking => 'Memeriksa Pembaruan…',
    _Status.available => 'Versi Baru Tersedia',
    _Status.upToDate => 'Aplikasi Sudah Terbaru',
    _Status.error => 'Gagal Memeriksa Pembaruan',
  };

  String get _popupSubtitle {
    final result = _result;
    final current = result?.currentVersion ?? '-';

    return switch (_status) {
      _Status.checking => 'Versi saat ini $current',
      _Status.available => 'Versi ${result?.latestVersion ?? '-'}',
      _Status.upToDate => result?.latestVersion == null
          ? 'Belum ada rilis publik.'
          : 'Versi saat ini $current',
      _Status.error =>
        result?.error ?? 'Tidak dapat memeriksa pembaruan saat ini.',
    };
  }
}
