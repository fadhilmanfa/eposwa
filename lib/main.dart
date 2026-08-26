import 'package:flutter/material.dart';
import 'package:eposwa/core/theme/app_theme.dart';
import 'package:eposwa/features/beranda/presentation/pages/beranda_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ePOSWA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BerandaPage(),
    );
  }
}
