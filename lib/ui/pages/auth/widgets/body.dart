import 'package:dynora_finance/ui/pages/auth/widgets/card_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
    required this.fade,
    required this.slide,
    required this.image,
    required this.form,
  });

  final Animation<double> fade;
  final Animation<Offset> slide;
  final String image;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            children: [
              SizedBox(height: 40.h),
              SizedBox(
                height: 220.h,
                child: SvgPicture.asset(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 40.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CardForm(form: form),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
