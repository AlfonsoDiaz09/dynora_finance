import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.chevron_left, color: Colors.white),
          Text("Febrero 2026", style: TextStyle(color: Colors.white)),
          Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}
