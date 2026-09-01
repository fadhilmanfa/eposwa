import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

enum SortDirection { asc, desc }

/// Definisi kolom untuk [ExcelTable].
class ExcelColumn {
  final String label;
  final double flex;
  final double minWidth;
  final bool sortable;

  const ExcelColumn({
    required this.label,
    this.flex = 1,
    this.minWidth = 100,
    this.sortable = true,
  });
}

/// Tabel bergaya Excel:
/// - geser (drag) pembatas kolom untuk resize
/// - auto-stretch justify: jika total lebar kolom < lebar layar,
///   kolom direntang proporsional agar mengisi penuh (justify).
/// - jika total > layar → scroll horizontal
/// - minimalis, adaptif monitor
class ExcelTable extends StatefulWidget {
  const ExcelTable({
    super.key,
    required this.columns,
    required this.rows,
    this.headerHeight = 42,
    this.rowHeight = 52,
    this.emptyWidget,
    this.wrapColumns = const {0},
    this.rowLeftBorders,
    this.sortColumnIndex,
    this.sortDirection,
    this.onSort,
  });

  final List<ExcelColumn> columns;
  /// rows[i][j] = widget sel baris-i kolom-j
  final List<List<Widget>> rows;
  final double headerHeight;
  final double rowHeight;
  final Widget? emptyWidget;
  /// indeks kolom yang boleh wrap multiline (tidak di-scale FittedBox)
  final Set<int> wrapColumns;
  /// warna left border per baris (null = tanpa border), panjang harus sama dengan rows.length
  final List<Color?>? rowLeftBorders;
  /// indeks kolom yang sedang aktif di-sort (null = tidak ada)
  final int? sortColumnIndex;
  /// arah sort aktif
  final SortDirection? sortDirection;
  /// dipanggil saat header kolom [sortable] diklik
  final ValueChanged<int>? onSort;

  @override
  State<ExcelTable> createState() => _ExcelTableState();
}

class _ExcelTableState extends State<ExcelTable> {
  List<double> _widths = [];
  bool _initialized = false;
  final ScrollController _hScroll = ScrollController();

  @override
  void dispose() {
    _hScroll.dispose();
    super.dispose();
  }

  void _ensureWidths(double available) {
    if (_initialized && _widths.length == widget.columns.length) return;
    final totalFlex = widget.columns.fold<double>(0, (s, c) => s + c.flex);
    _widths = widget.columns.map((c) {
      final w = available * c.flex / totalFlex;
      return w.clamp(c.minWidth, 600.0).toDouble();
    }).toList();
    // Jika total masih < available karena clamp min, biarkan (akan stretch nanti)
    // Jika total > available, tidak apa (akan scroll)
    _initialized = true;
  }

  List<double> _displayWidths(double available) {
    final sum = _widths.fold<double>(0, (s, w) => s + w);
    if (sum < available && available > 0) {
      final scale = available / sum;
      return _widths.map((w) => w * scale).toList();
    }
    return _widths;
  }

  void _onDrag(int index, double dx) {
    setState(() {
      final newW = (_widths[index] + dx)
          .clamp(widget.columns[index].minWidth, 600.0)
          .toDouble();
      final delta = newW - _widths[index];
      // Untuk kolom internal, coba jaga total tetap → kurangi kolom sebelah
      // agar justify tetap terjaga tanpa scaling semua.
      if (index < _widths.length - 1 && delta != 0) {
        final nextMin = widget.columns[index + 1].minWidth;
        double nextW = _widths[index + 1] - delta;
        if (nextW < nextMin) {
          // next tidak bisa mengecil lagi → batasi delta
          final allowed = _widths[index + 1] - nextMin;
          // allowed adalah max shrink yang bisa dilakukan next
          // delta positif (memperbesar index) → butuh shrink next sebesar delta
          // jika allowed < delta, batasi
          if (delta > 0) {
            final cappedDelta = allowed;
            _widths[index] += cappedDelta;
            _widths[index + 1] = nextMin;
          } else {
            // delta negatif (memperkecil index) → next membesar, tidak ada batas min pada next untuk membesar
            _widths[index] = newW;
            _widths[index + 1] -= delta; // delta negatif jadi tambah
          }
        } else {
          _widths[index] = newW;
          _widths[index + 1] = nextW;
        }
      } else {
        // kolom terakhir → bebas, total bisa berubah (scroll jika melebihi layar)
        _widths[index] = newW;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        // available bisa infinite saat di dalam scroll? Di sini constraints dari Container putih,
        // sudah finite (lebar card). Jadi aman.
        final safeAvailable = available.isFinite ? available : 900.0;
        _ensureWidths(safeAvailable);
        final display = _displayWidths(safeAvailable);
        final tableWidth = display.fold<double>(0, (s, w) => s + w);
        final needsHScroll = tableWidth > safeAvailable + 0.5;

        Widget table = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(display),
            ...List.generate(widget.rows.length, (r) => _buildRow(r, display)),
          ],
        );

        if (needsHScroll) {
          table = Scrollbar(
            controller: _hScroll,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _hScroll,
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: tableWidth, child: table),
            ),
          );
        } else {
          // justify: table sudah di-stretch ke available
          table = SizedBox(width: safeAvailable, child: table);
        }

        // Batasi tinggi untuk vertical scroll jika banyak baris? Biarkan natural.
        // Jika ingin scroll vertikal, bungkus, tapi di page sudah ada SingleChildScrollView luar.
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: table,
        );
      },
    );
  }

  Widget _buildHeader(List<double> display) {
    return Container(
      height: widget.headerHeight,
      decoration: const BoxDecoration(
        color: AppColors.sectionLight,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: List.generate(widget.columns.length, (i) {
          final col = widget.columns[i];
          final isActive = widget.sortColumnIndex == i;
          final isSortable = col.sortable && widget.onSort != null;
          final labelColor = isActive
              ? AppColors.primary
              : AppColors.textMuted;

          final labelWidget = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                i == 0 ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  col.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: i == 0 ? TextAlign.left : TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: labelColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (isActive)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    widget.sortDirection == SortDirection.asc
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ),
            ],
          );

          final labelContent = FittedBox(
            fit: BoxFit.scaleDown,
            alignment: i == 0 ? Alignment.centerLeft : Alignment.center,
            child: labelWidget,
          );

          return SizedBox(
            width: display[i],
            child: Stack(
              children: [
                // label — kolom pertama rata kiri, sisanya center
                Positioned.fill(
                  child: isSortable
                      ? _SortableHeaderCell(
                          first: i == 0,
                          content: labelContent,
                          active: isActive,
                          onTap: () => widget.onSort!(i),
                        )
                      : Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(
                            alignment: i == 0
                                ? Alignment.centerLeft
                                : Alignment.center,
                            child: labelContent,
                          ),
                        ),
                ),
                // single vertical divider + drag handle
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: _ResizeHandle(
                    onDrag: (dx) => _onDrag(i, dx),
                    isLast: i == widget.columns.length - 1,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRow(int rowIndex, List<double> display) {
    final cells = widget.rows[rowIndex];
    final isEven = rowIndex % 2 == 0;
    final leftBorderColor = widget.rowLeftBorders != null &&
            rowIndex < widget.rowLeftBorders!.length
        ? widget.rowLeftBorders![rowIndex]
        : null;

    // Jika ada left border, kurangi lebar kolom pertama agar total tetap = tableWidth
    // sehingga border 2.5 tidak menyebabkan overflow (Row offset 2.5).
    final adjustedDisplay = leftBorderColor != null
        ? [
            (display[0] - 2.5).clamp(widget.columns[0].minWidth - 2.5, 600.0).toDouble(),
            ...display.sublist(1),
          ]
        : display;

    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(widget.columns.length, (i) {
        final cell = i < cells.length ? cells[i] : const SizedBox.shrink();
        final shouldWrap = widget.wrapColumns.contains(i);
        return SizedBox(
          width: adjustedDisplay[i],
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Align(
                  alignment: shouldWrap ? Alignment.centerLeft : Alignment.center,
                  child: shouldWrap
                      ? cell
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: cell,
                        ),
                ),
              ),
              if (i > 0)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  child: Container(width: 1, color: AppColors.borderLight),
                ),
            ],
          ),
        );
      }),
    );

    if (leftBorderColor != null) {
      return Container(
        constraints: BoxConstraints(minHeight: widget.rowHeight),
        decoration: BoxDecoration(
          color: isEven ? Colors.white : const Color(0xFFFCFDFF),
          border: const Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 2.5, color: leftBorderColor),
              Expanded(child: rowContent),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(minHeight: widget.rowHeight),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFFCFDFF),
        border: const Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: rowContent,
    );
  }
}

class _SortableHeaderCell extends StatefulWidget {
  const _SortableHeaderCell({
    required this.first,
    required this.content,
    required this.active,
    required this.onTap,
  });

  final bool first;
  final Widget content;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_SortableHeaderCell> createState() => _SortableHeaderCellState();
}

class _SortableHeaderCellState extends State<_SortableHeaderCell> {
  bool _hover = false;
  bool _pressed = false;

  Color get _bg {
    if (_pressed) return AppColors.primary.withValues(alpha: 0.10);
    if (_hover) return AppColors.primary.withValues(alpha: 0.06);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: widget.first
              ? Alignment.centerLeft
              : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: widget.content,
        ),
      ),
    );
  }
}

class _ResizeHandle extends StatefulWidget {
  const _ResizeHandle({required this.onDrag, this.isLast = false});
  final ValueChanged<double> onDrag;
  final bool isLast;

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _hover = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => setState(() => _dragging = true),
        onHorizontalDragEnd: (_) => setState(() => _dragging = false),
        onHorizontalDragUpdate: (d) => widget.onDrag(d.delta.dx),
        child: Container(
          width: 12,
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: _dragging
                  ? AppColors.primary
                  : _hover
                      ? AppColors.borderMedium
                      : widget.isLast
                          ? Colors.transparent
                          : AppColors.borderLight,
            ),
          ),
        ),
      ),
    );
  }
}
