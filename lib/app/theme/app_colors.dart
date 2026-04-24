import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xff7F00FF);
  static const secondary = Color(0xffE100FF);

  static const background = Color(0xff0F0F1A);
  static const surface = Color(0xff1A1A2E);
  static const surfaceVariant = Color(0xff25253A);

  static const textPrimary = Color(0xFFFFFFFF);

  static const success = Colors.greenAccent;
  static const error = Colors.redAccent;
  static const warning = Colors.orangeAccent;
  static const info = Colors.blueAccent;

  static Color primary20 = AppColors.primary.withValues(alpha: 0.2);
  static Color primary40 = AppColors.primary.withValues(alpha: 0.4);
  static Color primary70 = AppColors.primary.withValues(alpha: 0.7);
  static Color textPrimary38 = AppColors.textPrimary.withValues(alpha: 0.38);
  static Color textPrimary70 = AppColors.textPrimary.withValues(alpha: 0.7);
  static Color textPrimary85 = AppColors.textPrimary.withValues(alpha: 0.85);
}
