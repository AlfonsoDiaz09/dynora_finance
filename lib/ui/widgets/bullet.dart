import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Bullet extends StatelessWidget {
  const Bullet({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: Color(0xFFB14CFF),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
