import 'dart:async';

import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/core/services/session_service.dart';
import 'package:eposwa/features/pendaftaran/data/peserta_repository.dart';
import 'package:eposwa/features/skrining/data/skrining_repository.dart';

import '../../domain/chart_periode.dart';
import '../../domain/dashboard_data.dart';
import '../../domain/tanggal_helper.dart';
import '../widgets/daily_analytics_chart.dart';
import '../widgets/min_stat_card.dart';

/// Halaman Greeting & Dashboard Overview - Minimalis dengan Grafik Harian.
class GreetingPage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const GreetingPage({super.key, this.onNavigate});

  @override
  State<GreetingPage> createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage> {
  List<Peserta> _pesertas = const [];
  List<SkriningRecord> _skriningRecords = const [];
  ChartPeriode _periode = ChartPeriode.mingguIni;
  RentangTanggal? _customRange;
  bool _loading = true;
  bool _error = false;

  late final PesertaRepository _pesertaRepository;
  late final SkriningRepository _skriningRepository;
  StreamSubscription<List<Peserta>>? _pesertaSubscription;
  StreamSubscription<List<SkriningRecord>>? _skriningSubscription;

  @override
  void initState() {
    super.initState();
    final db = getAppDatabase();
    _pesertaRepository = PesertaRepository(db);
    _skriningRepository = SkriningRepository(db);
    _subscribe();
  }

  @override
  void dispose() {
    _pesertaSubscription?.cancel();
    _skriningSubscription?.cancel();
    super.dispose();
  }

  void _subscribe() {
    _pesertaSubscription = _pesertaRepository.watchAll().listen(
          (items) => _onData(() => _pesertas = items),
          onError: _onError,
        );
    _skriningSubscription = _skriningRepository.watchAll().listen(
          (items) => _onData(() => _skriningRecords = items),
          onError: _onError,
        );
  }

  void _onData(VoidCallback assign) {
    if (!mounted) return;
    setState(() {
      assign();
      _loading = false;
      _error = false;
    });
  }

  void _onError(Object error, StackTrace stackTrace) {
    if (!mounted) return;
    setState(() {
      _error = true;
      _loading = false;
    });
  }

  void _retry() {
    _pesertaSubscription?.cancel();
    _skriningSubscription?.cancel();
    setState(() {
      _loading = true;
      _error = false;
    });
    _subscribe();
  }

  DashboardData get _dashboard => DashboardData.hitung(
        pesertas: _pesertas,
        skrining: _skriningRecords,
        periode: _periode,
        customRange: _customRange,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.scaleSpace(16, medium: 24, expanded: 32),
          vertical: context.scaleSpace(20, medium: 24, expanded: 28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Ringkas & Elegan
            _buildHeader(),

            const SizedBox(height: 28),

            // 2. Status & Grafik
            if (_error)
              _buildError()
            else if (_loading)
              _buildLoading()
            else ...[
              _buildMetricsRow(_dashboard),
              const SizedBox(height: 32),
              DailyAnalyticsChart(
                aktivitas: _dashboard.aktivitas,
                periode: _periode,
                customRange: _customRange,
                onPeriodeChanged: (periode) =>
                    setState(() => _periode = periode),
                onCustomRangeSelected: (range) =>
                    setState(() => _customRange = range),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final nama = SessionService.currentAdmin?.namaLengkap ?? 'Administrator';
    return Text(
      'Halo, $nama 👋',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        fontFamily: 'Inter',
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildMetricsRow(DashboardData data) {
    final cards = [
      MinStatCard(
        label: 'Pendaftaran Hari Ini',
        value: formatAngka(data.pendaftaranHariIni),
      ),
      MinStatCard(
        label: 'Sudah Screening',
        value: formatAngka(data.sudahScreening),
      ),
      MinStatCard(
        label: 'Total Terdaftar',
        value: formatAngka(data.totalTerdaftar),
      ),
    ];

    // Layar sangat sempit: 1 kolom agar tidak overflow
    if (context.isCompact) {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 16),
          cards[1],
          const SizedBox(height: 16),
          cards[2],
        ],
      );
    }

    // Layar medium: 2 kartu atas, 1 kartu di bawah
    if (context.isMedium) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: cards[2])]),
        ],
      );
    }

    // Layar lebar: 3 kolom
    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 16),
        Expanded(child: cards[1]),
        const SizedBox(width: 16),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat data dashboard',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _retry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}