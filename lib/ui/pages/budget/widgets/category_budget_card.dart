import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryBudgetCard extends StatelessWidget {
  final String category;
  final double spent;
  final double total;

  const CategoryBudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double percent = spent / total;
    double remaining = total - spent;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
              Text(
                "\$${remaining.toStringAsFixed(0)} libres",
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8.h,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent > 0.9 ? Colors.red : Colors.purpleAccent,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "\$${spent.toStringAsFixed(0)} de \$${total.toStringAsFixed(0)}",
            style: TextStyle(color: Colors.white54, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
