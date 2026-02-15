import 'package:dynora_finance/ui/pages/movements/widgets/summary_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionsSummaryCard extends StatelessWidget {
  const TransactionsSummaryCard({super.key});

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
            amount: "\$18,000",
            color: Colors.greenAccent,
          ),
          SummaryItem(
            title: "Gastos",
            amount: "\$7,540",
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}