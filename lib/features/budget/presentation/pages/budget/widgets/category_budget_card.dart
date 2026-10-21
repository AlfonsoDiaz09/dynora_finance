import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryBudgetCard extends StatelessWidget {
  final String category;
  final double spent;
  final double total;
  final VoidCallback? onTap;

  const CategoryBudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double percent = total > 0 ? spent / total : 0;
    double remaining = total - spent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
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
                  remaining >= 0
                      ? "${Formatters.currencyNoDecimals(remaining)} libres"
                      : "${Formatters.currencyNoDecimals(-remaining)} excedido",
                  style: TextStyle(
                    color: AppColors.textPrimary70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8.h,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percent > 0.9 ? Colors.red : Colors.purpleAccent,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "${Formatters.currencyNoDecimals(spent)} de ${Formatters.currencyNoDecimals(total)}",
              style: TextStyle(color: AppColors.textPrimary70, fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}
