import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummaryItem extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const SummaryItem({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.white70)),
        SizedBox(height: 6.h),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
