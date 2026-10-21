import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum MovementType { income, expense, payment }

class RecentMovementItem extends StatelessWidget {
  const RecentMovementItem({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
  });

  final String title;
  final String date;
  final double amount;
  final MovementType type;

  Color get amountColor {
    switch (type) {
      case MovementType.income:
        return Colors.greenAccent;
      case MovementType.expense:
        return Colors.redAccent;
      case MovementType.payment:
        return Colors.blueAccent;
    }
  }

  String get formattedAmount {
    final prefix = type == MovementType.expense ? "-" : "+";
    return "$prefix\$${amount.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: amountColor.withValues(alpha: 0.2),
            child: Icon(
              type == MovementType.income
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: amountColor,
            ),
          ),
          SizedBox(width: 14.h),
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
                  date,
                  style: TextStyle(
                    color: AppColors.textPrimary70,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formattedAmount,
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
