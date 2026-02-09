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
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}