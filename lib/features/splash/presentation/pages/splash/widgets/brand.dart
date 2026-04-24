import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Brand extends StatelessWidget {
  const Brand({super.key, required this.fadeText});

  final Animation<double> fadeText;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeText,
      child: Text(
        'Dynora Finanzas',
        style: TextStyle(
          color: AppColors.textPrimary85,
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
