import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MovementFilterBar extends StatelessWidget {
  const MovementFilterBar({
    super.key,
    required this.monthLabel,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final String monthLabel;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPreviousMonth,
                  icon: Icon(Icons.chevron_left, color: Colors.white),
                ),
                Text(monthLabel, style: TextStyle(color: Colors.white)),
                IconButton(
                  onPressed: onNextMonth,
                  icon: Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Icon(Icons.filter_list, color: Colors.white),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }
}
