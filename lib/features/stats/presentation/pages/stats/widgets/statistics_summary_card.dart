import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/stats/presentation/pages/stats/widgets/summary_row.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticsSummaryCard extends StatelessWidget {
  const StatisticsSummaryCard({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
  });

  final double income;
  final double expense;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceVariant],
        ),
      ),
      child: Column(
        children: [
          SummaryRow(
            label: "Ingresos",
            value: Formatters.currencyNoDecimals(income),
            color: Colors.greenAccent,
          ),
          SizedBox(height: 16.h),
          SummaryRow(
            label: "Gastos",
            value: Formatters.currencyNoDecimals(expense),
            color: Colors.redAccent,
          ),
          Divider(height: 30.h, color: Colors.white24),
          SummaryRow(
            label: "Balance",
            value: Formatters.currencyNoDecimals(balance),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
