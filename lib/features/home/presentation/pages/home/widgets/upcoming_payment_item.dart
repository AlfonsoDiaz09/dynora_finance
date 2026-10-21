import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpcomingPaymentItem extends StatelessWidget {
  const UpcomingPaymentItem({
    super.key,
    required this.cardName,
    required this.dueDate,
    required this.daysLeft,
    required this.amount,
    this.onTap,
  });

  final String cardName;
  final String dueDate;
  final int daysLeft;

  /// Statement total to pay on [dueDate].
  final double amount;
  final VoidCallback? onTap;

  bool get isOverdue => daysLeft < 0;

  String get daysLeftLabel => switch (daysLeft) {
    -1 => "Vencido ayer",
    < 0 => "Vencido hace ${-daysLeft} días",
    0 => "Hoy",
    1 => "1 día",
    _ => "$daysLeft días",
  };

  Color get urgencyColor {
    if (daysLeft <= 3) return Colors.redAccent;
    if (daysLeft <= 7) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: urgencyColor.withValues(alpha: 0.2),
              child: Icon(Icons.credit_card, color: urgencyColor),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${isOverdue ? 'Venció' : 'Vence'}: $dueDate · ${Formatters.currency(amount)}",
                    style: TextStyle(
                      color: AppColors.textPrimary70,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              daysLeftLabel,
              style: TextStyle(
                color: urgencyColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
