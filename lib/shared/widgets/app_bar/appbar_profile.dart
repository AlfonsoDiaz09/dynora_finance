import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppbarProfile extends StatelessWidget {
  const AppbarProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff7F00FF).withValues(alpha: 0.2),
              border: Border.all(color: Color(0xffE100FF), width: 1.5),
            ),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12.w),
          Row(
            children: [
              Text(
                "Hola, Alfonso",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.6),
                size: 20.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
