import 'package:dynora_finance/features/movements/presentation/pages/movements/widgets/summary_item.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MovementsSummaryCard extends StatelessWidget {
  const MovementsSummaryCard({
    super.key,
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SummaryItem(
            title: "Ingresos",
            amount: Formatters.currencyNoDecimals(income),
            color: Colors.greenAccent,
          ),
          SummaryItem(
            title: "Gastos",
            amount: Formatters.currencyNoDecimals(expense),
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
