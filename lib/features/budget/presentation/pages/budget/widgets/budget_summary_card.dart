import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({
    super.key,
    required this.total,
    required this.spent,
  });

  final double total;
  final double spent;

  @override
  Widget build(BuildContext context) {
    double remaining = total - spent;
    double percent = total > 0 ? spent / total : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Presupuesto mensual", style: TextStyle(color: AppColors.textPrimary70)),
          SizedBox(height: 8.h),
          Text(
            remaining >= 0
                ? "${Formatters.currencyNoDecimals(remaining)} disponibles"
                : "${Formatters.currencyNoDecimals(-remaining)} excedido",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10.h,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "${Formatters.currencyNoDecimals(spent)} de ${Formatters.currencyNoDecimals(total)} usados",
            style: TextStyle(color: AppColors.textPrimary70),
          ),
        ],
      ),
    );
  }
}
