import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Método flexible para personalizar
  static TextStyle custom({
    TextStyle? base,
    double? size,
    FontWeight? weight,
    Color? color,
  }) {
    return (base ?? body).copyWith(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  // Para integrarlo con ThemeData
  static TextTheme get textTheme => const TextTheme(
    displayLarge: titleLarge,
        displayMedium: titleMedium,
        titleLarge: title,
        titleMedium: subtitle,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: button,
  );
  
  // Titulares grandes (AppBar, pantallas principales)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Subtítulos o secciones
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Texto de cuerpo (parrafos, labels)
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    // color: AppColors.textPrimary.withValues(alpha: 0.8),
  );

  // Texto secundario (descripciones, notas, captions)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    // color: AppColors.textPrimary.withValues(alpha: 0.6),
  );

  // Botones
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Inputs
  static const TextStyle input = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // Hint de inputs
  static TextStyle inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary.withValues(alpha: 0.4),
  );

  // Texto dentro de Cards
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle cardBody = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary.withValues(alpha: 0.7),
  );
}