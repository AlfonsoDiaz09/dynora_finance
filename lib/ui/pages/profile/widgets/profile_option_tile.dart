import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(icon, color: isDanger ? Colors.red : Colors.white),
              SizedBox(width: 15.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDanger ? Colors.red : Colors.white,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
