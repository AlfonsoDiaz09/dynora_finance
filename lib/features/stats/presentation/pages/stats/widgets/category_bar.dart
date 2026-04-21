import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryBar extends StatelessWidget {
  final String category;
  final double percentage;
  final Color color;

  const CategoryBar({
    super.key,
    required this.category,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category, style: TextStyle(color: Colors.white)),
        SizedBox(height: 6.h),
        Stack(
          children: [
            Container(
              height: 10.h,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 10.h,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
