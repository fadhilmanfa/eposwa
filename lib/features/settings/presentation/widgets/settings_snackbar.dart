import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

/// SnackBar seragam untuk fitur yang belum aktif (placeholder UI).
void showComingSoonSnackBar(BuildContext context, String fitur) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Fitur "$fitur" segera hadir.'),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
    ),
  );
}
