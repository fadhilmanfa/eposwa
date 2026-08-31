import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/features/pendaftaran/data/pendaftar_store.dart';

/// Dialog Command ala shadcn/ui untuk memilih pendaftar yang sudah terdaftar.
/// Muncul di tengah layar: pencarian di atas, daftar hasil di bawah.
/// - Klik / Enter pada hasil -> mengembalikan [Pendaftar] terpilih.
/// - Tidak ada hasil + tekan Enter -> otomatis mendaftarkan nama baru ke store.
Future<Pendaftar?> showPendaftarCommandDialog(BuildContext context) {
  return showDialog<Pendaftar>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (context) => const _PendaftarCommandDialog(),
  );
}

class _PendaftarCommandDialog extends StatefulWidget {
  const _PendaftarCommandDialog();

  @override
  State<_PendaftarCommandDialog> createState() =>
      _PendaftarCommandDialogState();
}

class _PendaftarCommandDialogState extends State<_PendaftarCommandDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  int _highlightIndex = 0;

  List<Pendaftar> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return PendaftarStore.instance.all;
    return PendaftarStore.instance.all
        .where((p) =>
            p.nama.toLowerCase().contains(query) ||
            p.nik.contains(query) ||
            p.program.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _moveHighlight(int delta) {
    final count = _filtered.length;
    if (count == 0) return;
    setState(() {
      _highlightIndex = (_highlightIndex + delta) % count;
      if (_highlightIndex < 0) _highlightIndex = count - 1;
    });
  }

  void _handleEnter() {
    final filtered = _filtered;
    if (filtered.isNotEmpty) {
      final target = filtered[_highlightIndex.clamp(0, filtered.length - 1)];
      Navigator.of(context).pop(target);
      return;
    }

    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final pendaftarBaru = Pendaftar(nama: query, nik: '-', program: '-');
    PendaftarStore.instance.add(pendaftarBaru);
    Navigator.of(context).pop(pendaftarBaru);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _handleEnter();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(),
            const Divider(height: 1, color: AppColors.borderLight),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 340),
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _buildOption(filtered[index], index),
                    ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Focus(
              onKeyEvent: _onKeyEvent,
              child: TextField(
                controller: _searchController,
                focusNode: _inputFocus,
                autofocus: true,
                onChanged: (_) => setState(() => _highlightIndex = 0),
                onSubmitted: (_) => _handleEnter(),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari nama pendaftar...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    fontFamily: 'Inter',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _highlightIndex = 0);
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(Pendaftar pendaftar, int index) {
    final isHighlighted = index == _highlightIndex;

    return MouseRegion(
      onEnter: (_) => setState(() => _highlightIndex = index),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(pendaftar),
        child: Container(
          color: isHighlighted
              ? AppColors.primarySoft
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.sectionCardBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: isHighlighted
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pendaftar.nama,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIK ${pendaftar.nik} · ${pendaftar.program}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              if (isHighlighted)
                const Icon(
                  Icons.keyboard_return_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              if (isHighlighted) const SizedBox(width: 10),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 17,
                  color: Colors.redAccent,
                ),
                tooltip: 'Hapus Pendaftar',
                visualDensity: VisualDensity.compact,
                onPressed: () => _confirmDelete(pendaftar),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Pendaftar pendaftar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(maxWidth: 380),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus Pendaftar',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus pendaftar "${pendaftar.nama}"? '
                'Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.borderMedium),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Batal',
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
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        PendaftarStore.instance.remove(pendaftar);
        if (_filtered.isEmpty) {
          _highlightIndex = 0;
        } else {
          _highlightIndex = _highlightIndex.clamp(0, _filtered.length - 1);
        }
      });
    }
  }

  Widget _buildEmptyState() {
    final query = _searchController.text.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 36, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada hasil',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            query.isEmpty
                ? 'Belum ada pendaftar terdaftar.'
                : 'Tekan Enter untuk mendaftarkan "$query" sebagai pendaftar baru.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AppColors.textMuted,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.sectionLight,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
        border: const Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              size: 14, color: AppColors.textMuted),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '↑↓ untuk navigasi · Enter untuk memilih, atau mendaftarkan nama baru',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}