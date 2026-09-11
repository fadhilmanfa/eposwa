import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/services/import_service.dart';
import 'package:eposwa/core/widgets/animated_segmented_selector.dart';

/// Modal daftar peserta di dalam file SQL. User memilih siapa saja yang mau
/// di-import (per baris atau lewat "Pilih semua").
/// Mengembalikan himpunan NIK terpilih, atau null bila dibatalkan.
Future<Set<String>?> showImportCandidatesDialog(
  BuildContext context,
  List<ImportCandidate> candidates,
) {
  return showDialog<Set<String>>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => _ImportCandidatesDialog(candidates: candidates),
  );
}

/// Modal konfirmasi untuk peserta yang NIK-nya sudah ada di database.
/// Tiap peserta dipilih aksinya sendiri: Gabung / Ganti / Tolak.
/// Mengembalikan peta NIK → aksi, atau null bila dibatalkan.
Future<Map<String, ImportStrategy>?> showImportConflictDialog(
  BuildContext context,
  List<ImportCandidate> conflicts,
) {
  return showDialog<Map<String, ImportStrategy>>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => _ImportConflictDialog(conflicts: conflicts),
  );
}

class _ImportCandidatesDialog extends StatefulWidget {
  final List<ImportCandidate> candidates;

  const _ImportCandidatesDialog({required this.candidates});

  @override
  State<_ImportCandidatesDialog> createState() =>
      _ImportCandidatesDialogState();
}

class _ImportCandidatesDialogState extends State<_ImportCandidatesDialog> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.candidates.map((c) => c.nik).toSet();
  }

  int get _existingCount => widget.candidates.where((c) => c.isExisting).length;

  bool get _allSelected => _selected.length == widget.candidates.length;

  void _toggleAll(bool value) {
    setState(() {
      _selected.clear();
      if (value) {
        _selected.addAll(widget.candidates.map((c) => c.nik));
      }
    });
  }

  void _toggleOne(String nik, bool value) {
    setState(() {
      if (value) {
        _selected.add(nik);
      } else {
        _selected.remove(nik);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.candidates.length;
    final baru = total - _existingCount;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              icon: Icons.download_rounded,
              iconBackground: AppColors.primarySoft,
              iconColor: AppColors.primary,
              title: 'Import Data',
              subtitle:
                  'File berisi $total peserta — $baru baru, $_existingCount sudah ada.',
            ),
            Container(
              color: AppColors.sectionLight,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  _SelectionCheckbox(
                    value: _allSelected,
                    onChanged: _toggleAll,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pilih semua',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: total,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, index) {
                  final candidate = widget.candidates[index];
                  return _CandidateRow(
                    candidate: candidate,
                    selected: _selected.contains(candidate.nik),
                    onChanged: (value) => _toggleOne(candidate.nik, value),
                  );
                },
              ),
            ),
            _DialogFooter(
              confirmLabel: 'Import (${_selected.length})',
              confirmEnabled: _selected.isNotEmpty,
              onConfirm: () => Navigator.of(context).pop(_selected),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportConflictDialog extends StatefulWidget {
  final List<ImportCandidate> conflicts;

  const _ImportConflictDialog({required this.conflicts});

  @override
  State<_ImportConflictDialog> createState() => _ImportConflictDialogState();
}

class _ImportConflictDialogState extends State<_ImportConflictDialog> {
  late final Map<String, ImportStrategy> _actions;

  @override
  void initState() {
    super.initState();
    _actions = {
      for (final conflict in widget.conflicts) conflict.nik: ImportStrategy.merge,
    };
  }

  @override
  Widget build(BuildContext context) {
    final conflicts = widget.conflicts;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 620,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              icon: Icons.warning_amber_rounded,
              iconBackground: AppColors.badgeBgWarning,
              iconColor: AppColors.badgeTextWarning,
              title: 'Data Konflik',
              subtitle:
                  '${conflicts.length} peserta sudah ada di database. Pilih tindakan untuk masing-masing.',
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: conflicts.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, index) {
                  final conflict = conflicts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conflict.nama,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${conflict.nik}  ·  '
                                '${conflict.skriningCount > 0 ? '${conflict.skriningCount} skrining di file' : 'tanpa skrining'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 220,
                          child: AnimatedSegmentedSelector<ImportStrategy>(
                            height: 38,
                            selected: _actions[conflict.nik],
                            options: const [
                              SegmentedOption(
                                value: ImportStrategy.merge,
                                label: 'Gabung',
                              ),
                              SegmentedOption(
                                value: ImportStrategy.replace,
                                label: 'Ganti',
                              ),
                              SegmentedOption(
                                value: ImportStrategy.skip,
                                label: 'Tolak',
                              ),
                            ],
                            onChanged: (value) => setState(
                              () => _actions[conflict.nik] = value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            _DialogFooter(
              confirmLabel: 'Import',
              onConfirm: () => Navigator.of(context).pop(_actions),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _DialogHeader({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
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
                  subtitle,
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
}

class _DialogFooter extends StatelessWidget {
  final String confirmLabel;
  final bool confirmEnabled;
  final VoidCallback onConfirm;

  const _DialogFooter({
    required this.confirmLabel,
    required this.onConfirm,
    this.confirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Navigator.of(context).pop(),
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
              onPressed: confirmEnabled ? onConfirm : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final ImportCandidate candidate;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _CandidateRow({
    required this.candidate,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!selected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            _SelectionCheckbox(value: selected, onChanged: onChanged),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.nama,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    candidate.nik,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusBadge(
              label: candidate.isExisting ? 'Sudah ada' : 'Baru',
              background: candidate.isExisting
                  ? AppColors.badgeBgWarning
                  : AppColors.badgeBgSuccess,
              foreground: candidate.isExisting
                  ? AppColors.badgeTextWarning
                  : AppColors.badgeTextSuccess,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: foreground,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _SelectionCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SelectionCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Checkbox(
        value: value,
        activeColor: AppColors.primary,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (val) => onChanged(val ?? false),
      ),
    );
  }
}
