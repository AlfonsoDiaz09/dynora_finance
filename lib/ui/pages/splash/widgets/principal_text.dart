import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrincipalText extends StatelessWidget {
  const PrincipalText({
    super.key, 
    required this.fadeText, 
    required this.slideText});

  final Animation<double> fadeText;
  final Animation<Offset> slideText;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeText,
      child: SlideTransition(
        position: slideText,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              Text(
                'Controla gastos\ne ingresos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32.sp,
                  height: 1.2.h,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
              SizedBox(height: 12.h),
              Text(
                'sin complicaciones',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB455FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
