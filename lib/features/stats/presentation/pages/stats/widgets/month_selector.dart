import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(label, style: TextStyle(color: Colors.white)),
          IconButton(
            onPressed: onNext,
            icon: Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
