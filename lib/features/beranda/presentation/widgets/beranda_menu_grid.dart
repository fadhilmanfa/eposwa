import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_menu_card.dart';

/// Grid 3 Card Layanan - Rata kiri & mengambang (floating) naik menimpa setengah jumbotron.
class BerandaMenuGrid extends StatelessWidget {
  const BerandaMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    // Nilai overlap untuk menaikkan 3 kartu ke setengah jumbotron
    final overlap = context.scaleSpace(50, medium: 80, expanded: 110, large: 130);
    final padBottom = context.scaleSpace(32, medium: 48, expanded: 64);

    // Konten kartu tanpa Transform: akan digeser via _OverlapWrapper di layer layout,
    // sehingga hit-test / hover tetap akurat di area yang overlap dengan jumbotron.
    final content = Padding(
      padding: EdgeInsets.only(
        bottom: padBottom > overlap ? padBottom - overlap : 8,
      ),
      child: AppContainer(
        child: isCompact ? _buildCompactCards() : _buildWideCards(),
      ),
    );

    return _OverlapWrapper(
      overlap: overlap,
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: content,
      ),
    );
  }

  Widget _buildCompactCards() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BerandaMenuCard(
          label: 'Pendaftaran Pasien',
          icon: Icons.how_to_reg_rounded,
          description: 'Daftarkan diri atau anggota keluarga Anda untuk mendapatkan pendampingan berkala dari kader.',
        ),
        SizedBox(height: 16),
        BerandaMenuCard(
          label: 'Skrining Jiwa Mandiri',
          icon: Icons.quiz_rounded,
          description: 'Evaluasi kondisi psikologis dengan kuesioner tervalidasi dan rekomendasi tindak lanjut.',
        ),
        SizedBox(height: 16),
        BerandaMenuCard(
          label: 'Database & Rekapitulasi',
          icon: Icons.analytics_rounded,
          description: 'Pengelolaan data rekam posyandu, statistik kunjungan, serta arsip rujukan ke Puskesmas.',
        ),
      ],
    );
  }

  Widget _buildWideCards() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BerandaMenuCard(
            label: 'Pendaftaran Pasien',
            icon: Icons.how_to_reg_rounded,
            description: 'Daftarkan diri atau anggota keluarga Anda untuk mendapatkan pendampingan berkala dari kader.',
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: BerandaMenuCard(
            label: 'Skrining Jiwa Mandiri',
            icon: Icons.quiz_rounded,
            description: 'Evaluasi kondisi psikologis dengan kuesioner tervalidasi dan rekomendasi tindak lanjut.',
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: BerandaMenuCard(
            label: 'Database & Rekapitulasi',
            icon: Icons.analytics_rounded,
            description: 'Pengelolaan data rekam posyandu, statistik kunjungan, serta arsip rujukan ke Puskesmas.',
          ),
        ),
      ],
    );
  }
}

/// Wrapper yang menggeser child ke atas sebesar [overlap] di fase **layout**
/// bukan hanya paint, sehingga:
/// - tinggi [Stack]/[Column] induk berkurang sebesar overlap (tidak ada gap kosong)
/// - hit-test / MouseRegion hover mencakup area overlap di atas jumbotron
/// Sebelumnya pakai `Transform.translate` yang hanya menggeser paint → bagian
/// atas kartu (card 3 di sisi kanan) berada di luar bounds parent Container,
/// sehingga hover hanya aktif kalau kursor agak ke bawah (di dalam bounds).
class _OverlapWrapper extends SingleChildRenderObjectWidget {
  const _OverlapWrapper({required this.overlap, required super.child});

  final double overlap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderOverlapWrapper(overlap: overlap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderOverlapWrapper renderObject,
  ) {
    renderObject.overlap = overlap;
  }
}

class RenderOverlapWrapper extends RenderProxyBox {
  RenderOverlapWrapper({required double overlap}) : _overlap = overlap; // ignore: prefer_initializing_formals

  double _overlap;
  set overlap(double value) {
    if (_overlap == value) return;
    _overlap = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  @override
  void performLayout() {
    if (child == null) {
      size = Size.zero;
      return;
    }
    // Layout child dengan constraints penuh dari parent (Column/Sliver).
    child!.layout(constraints, parentUsesSize: true);
    final childSize = child!.size;
    // Tinggi wrapper dikurangi overlap agar Column/Sliver tinggi total
    // = jumbotron + kartu - overlap (visual presisi, tanpa gap).
    final h = (childSize.height - _overlap).clamp(0.0, double.infinity);
    size = Size(childSize.width, h);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    // Geser child ke atas sebesar overlap di fase paint, sinkron dengan layout.
    context.paintChild(child!, offset + Offset(0, -_overlap));
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    // position lokal terhadap wrapper (0,0 di pojok kiri atas wrapper).
    // Child dipaint di offset (0, -overlap), jadi posisi lokal child = position + overlap.
    final adjusted = Offset(position.dx, position.dy + _overlap);
    if (adjusted.dx < 0 ||
        adjusted.dx > child!.size.width ||
        adjusted.dy < 0 ||
        adjusted.dy > child!.size.height) {
      return false;
    }
    return child!.hitTest(result, position: adjusted);
  }
}
