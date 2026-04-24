import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    // Paleta principal
    colorScheme: ColorScheme.dark(
      brightness: Brightness.dark,

      primary: AppColors.primary,
      onPrimary: Colors.white,

      secondary: AppColors.secondary,
      onSecondary: Colors.white,

      error: AppColors.error,
      onError: Colors.white,

      background: AppColors.background,
      onBackground: AppColors.textPrimary,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textPrimary,

      outline: Colors.white24,
      shadow: Colors.black,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: AppColors.primary,
    ),

    // Textos globales
    textTheme:
        const TextTheme(
          titleLarge: AppTextStyles.title,
          bodyMedium: AppTextStyles.body,
          labelLarge: AppTextStyles.button,
        ).apply(
          bodyColor: AppColors.surface,
          displayColor: AppColors.surface,
        ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surface,
      elevation: 4,
      shadowColor: AppColors.surfaceVariant,
      titleTextStyle: AppTextStyles.title,
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      hintStyle: AppTextStyles.inputHint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    // Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.surface,
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: AppColors.surface,
      shadowColor: AppColors.surfaceVariant,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Iconos
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
  );
}
