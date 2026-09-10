import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/features/beranda/presentation/pages/beranda_page.dart';

/// Splash screen ePOSWA.
/// Menampilkan logo UMS & Puskesmas dan progress bar "memuat": mulus di awal,
/// tersendat-sendat di akhir ([SmoothThenStutterCurve]).
/// Otomatis pindah ke [BerandaPage] setelah ±5 detik dengan transisi fade.
class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _stutter;
  late final AnimationController _fadeOut;
  late final CurvedAnimation _fadeOutCurve;
  late final Animation<double> _fadeOutOpacity;

  static const Duration _duration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _stutter = CurvedAnimation(
      parent: _controller,
      curve: const SmoothThenStutterCurve(),
    );
    _fadeOut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeOutCurve = CurvedAnimation(parent: _fadeOut, curve: Curves.easeIn);
    _fadeOutOpacity = Tween<double>(begin: 1, end: 0).animate(_fadeOutCurve);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fadeOut.forward();
      }
    });
    _fadeOut.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToHome();
      }
    });
    _controller.forward();
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => const BerandaPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeOut.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FadeTransition(
        opacity: _fadeOutOpacity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/ums.png', height: 80),
                  const SizedBox(width: 28),
                  Image.asset('assets/images/logo_kab.png', height: 60),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 260,
                child: AnimatedBuilder(
                  animation: _stutter,
                  builder: (context, _) => LinearProgressIndicator(
                    value: _stutter.value,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: AppColors.borderLight,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kurva progres yang bergerak mulus di awal, lalu tersendat-sendat di akhir:
/// bagian awal mengikuti easing halus, bagian akhir membagi sisa progres
/// menjadi langkah-langkah kecil yang melaju cepat (ease-out) lalu berhenti
/// sebentar sebelum langkah berikutnya.
class SmoothThenStutterCurve extends Curve {
  const SmoothThenStutterCurve({
    this.smoothFraction = 0.5,
    this.steps = 12,
    this.moveFraction = 0.35,
  });

  /// Porsi awal (0..1) yang bergerak mulus tanpa sendat.
  final double smoothFraction;

  /// Jumlah langkah "sendat" pada bagian akhir.
  final int steps;

  /// Porsi durasi tiap langkah yang dipakai untuk bergerak (sisanya jeda).
  final double moveFraction;

  @override
  double transformInternal(double t) {
    if (t <= smoothFraction) {
      return smoothFraction * Curves.easeInOut.transform(t / smoothFraction);
    }

    final stutterT = (t - smoothFraction) / (1 - smoothFraction);
    final scaled = (stutterT * steps).clamp(0.0, steps.toDouble());
    final stepIndex = scaled.floorToDouble().clamp(0.0, (steps - 1).toDouble());
    final local = scaled - stepIndex;
    final progress = (local / moveFraction).clamp(0.0, 1.0);
    final stepProgress =
        (stepIndex + Curves.easeOut.transform(progress)) / steps;
    return smoothFraction + (1 - smoothFraction) * stepProgress;
  }
}
