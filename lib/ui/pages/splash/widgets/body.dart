import 'package:dynora_finance/ui/pages/splash/widgets/brand.dart';
import 'package:dynora_finance/ui/pages/splash/widgets/button_start.dart';
import 'package:dynora_finance/ui/pages/splash/widgets/illustration.dart';
import 'package:dynora_finance/ui/pages/splash/widgets/principal_text.dart';
import 'package:dynora_finance/ui/pages/splash/widgets/secondary_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Body extends StatelessWidget {
  const Body({
    super.key, 
    required this.fadeText, 
    required this.slideText, 
    required this.fadeImage, 
    required this.scaleImage});

  final Animation<double> fadeText;
  final Animation<Offset> slideText;
  final Animation<double> fadeImage;
  final Animation<double> scaleImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(18, 18, 18, 1),
            Color.fromRGBO(30, 30, 30, 1),
            Color.fromRGBO(42, 42, 42, 1),
          ])),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            Brand(fadeText: fadeText),
            SizedBox(height: 40.h),
            PrincipalText(fadeText: fadeText, slideText: slideText),
            Spacer(),
            Illustration(fadeImage: fadeImage, scaleImage: scaleImage),
            Spacer(),
            ButtonStart(),
            SizedBox(height: 12),
            SecondaryText(fadeImage: fadeImage),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
