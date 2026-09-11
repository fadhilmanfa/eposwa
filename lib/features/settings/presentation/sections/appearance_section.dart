import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/features/settings/presentation/widgets/settings_snackbar.dart';
import 'package:eposwa/features/settings/presentation/widgets/settings_tile.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

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
            icon: Icons.dark_mode_outlined,
            title: 'Mode gelap',
            subtitle: 'Gunakan tema gelap di seluruh aplikasi',
            trailing: Switch(
              value: false,
              onChanged: (_) => showComingSoonSnackBar(context, 'Mode gelap'),
            ),
            onTap: () => showComingSoonSnackBar(context, 'Mode gelap'),
          ),
        ),
      ),
    );
  }
}
