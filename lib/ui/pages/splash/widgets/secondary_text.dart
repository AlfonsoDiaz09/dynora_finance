import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SecondaryText extends StatelessWidget {
  const SecondaryText({super.key, required this.fadeImage});

  final Animation<double> fadeImage;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeImage,
      child: Text(
        'Tu dinero, claro y bajo control',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6), 
          fontSize: 14.sp)));
  }
}
