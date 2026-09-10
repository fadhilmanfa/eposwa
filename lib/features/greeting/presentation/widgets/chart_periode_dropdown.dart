import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

import '../../domain/chart_periode.dart';
import '../../domain/tanggal_helper.dart';

/// Dropdown pemilih periode untuk grafik aktivitas.
///
/// Saat memilih "Kustom", date-range picker akan dibuka; hasil rentang disalurkan
/// lewat [onCustomRangeSelected].
class ChartPeriodeDropdown extends StatelessWidget {
  final ChartPeriode value;
  final ValueChanged<ChartPeriode> onChanged;
  final ValueChanged<RentangTanggal> onCustomRangeSelected;

  const ChartPeriodeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onCustomRangeSelected,
  });

  Future<void> _pilih(BuildContext context, ChartPeriode periode) async {
    if (periode != ChartPeriode.kustom) {
      onChanged(periode);
      return;
    }

    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 6)),
        end: now,
      ),
      helpText: 'Pilih rentang tanggal',
      saveText: 'Terapkan',
    );
    if (picked == null || !context.mounted) return;

    onChanged(ChartPeriode.kustom);
    onCustomRangeSelected(RentangTanggal(picked.start, picked.end));
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ChartPeriode>(
      initialValue: value,
      tooltip: 'Periode grafik',
      onSelected: (periode) => _pilih(context, periode),
      itemBuilder: (context) => ChartPeriode.values.map((periode) {
        final selected = periode == value;
        return PopupMenuItem(
          value: periode,
          child: Row(
            children: [
              Icon(
                selected ? Icons.check : Icons.calendar_today_outlined,
                size: 16,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(periode.label),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              value.label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}