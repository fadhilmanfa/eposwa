import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/features/settings/presentation/widgets/settings_snackbar.dart';
import 'package:eposwa/features/settings/presentation/widgets/settings_tile.dart';

class BehaviorSection extends StatelessWidget {
  const BehaviorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: SettingsTile(
            icon: Icons.rocket_launch_outlined,
            title: 'Buka aplikasi saat masuk Windows',
            subtitle:
                'ePOSWA dijalankan otomatis setiap kali Anda login ke Windows',
            trailing: Switch(
              value: false,
              onChanged: (_) => showComingSoonSnackBar(
                context,
                'Buka aplikasi saat masuk Windows',
              ),
            ),
            onTap: () => showComingSoonSnackBar(
              context,
              'Buka aplikasi saat masuk Windows',
            ),
          ),
        ),
      ),
    );
  }
}
