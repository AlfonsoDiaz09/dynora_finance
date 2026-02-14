import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final bool isExpense;

  const TransactionItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? Colors.redAccent : Colors.greenAccent;
    final prefix = isExpense ? "-" : "+";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(
              isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$prefix\$${amount.toStringAsFixed(2)}",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
