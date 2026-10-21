import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({
    super.key,
    required this.balance,
    required this.monthIncome,
    required this.monthExpense,
  });

  final double balance;
  final double monthIncome;
  final double monthExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Balance total", style: TextStyle(color: AppColors.textPrimary70)),
          SizedBox(height: 8.h),
          Text(
            Formatters.currency(balance),
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniSummary(
                label: "Ingresos",
                value: Formatters.currencyNoDecimals(monthIncome),
                color: Colors.greenAccent,
              ),
              _MiniSummary(
                label: "Gastos",
                value: Formatters.currencyNoDecimals(monthExpense),
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  const _MiniSummary({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textPrimary70)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }
}
