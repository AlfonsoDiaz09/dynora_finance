import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Illustration extends StatelessWidget {
  const Illustration({
    super.key,
    required this.fadeImage,
    required this.scaleImage});

  final Animation<double> fadeImage;
  final Animation<double> scaleImage;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeImage,
      child: ScaleTransition(
        scale: scaleImage,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SvgPicture.asset(
            'assets/img/business_vision.svg',
            height: 222.h,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
