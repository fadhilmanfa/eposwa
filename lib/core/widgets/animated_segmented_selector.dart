import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

/// Opsi tunggal untuk [AnimatedSegmentedSelector].
class SegmentedOption<T> {
  final T value;
  final String label;

  const SegmentedOption({required this.value, required this.label});
}

/// Pilihan tabular (mis. Ya/Tidak, Laki-laki/Perempuan)
/// dengan indikator yang meluncur (slide) ke opsi terpilih.
class AnimatedSegmentedSelector<T> extends StatefulWidget {
  final List<SegmentedOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;
  final double height;
  final bool error;

  const AnimatedSegmentedSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.height = 44,
    this.error = false,
  });

  @override
  State<AnimatedSegmentedSelector<T>> createState() =>
      _AnimatedSegmentedSelectorState<T>();
}

class _AnimatedSegmentedSelectorState<T>
    extends State<AnimatedSegmentedSelector<T>> {
  @override
  Widget build(BuildContext context) {
    final options = widget.options;

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.error ? Colors.redAccent : const Color(0xFFE2E8F0),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / options.length;
          final selectedIndex = widget.selected == null
              ? -1
              : options.indexWhere((o) => o.value == widget.selected);

          return Stack(
            children: [
              if (selectedIndex >= 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * segmentWidth + 3,
                  top: 3,
                  bottom: 3,
                  width: segmentWidth - 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.heroButton,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              Row(
                children: List.generate(options.length, (i) {
                  final option = options[i];
                  final isSelected = option.value == widget.selected;
                  return Expanded(
                    child: InkWell(
                      onTap: () => widget.onChanged(option.value),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                          fontFamily: 'Inter',
                        ),
                        child: Center(
                          child: Text(option.label),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}