import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/stats/presentation/pages/stats/widgets/summary_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticsSummaryCard extends StatelessWidget {
  const StatisticsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [AppColors.surface, Color(0xff25253A)],
        ),
      ),
      child: Column(
        children: [
          SummaryRow(
            label: "Ingresos",
            value: "\$18,000",
            color: Colors.greenAccent,
          ),
          SizedBox(height: 16.h),
          SummaryRow(
            label: "Gastos",
            value: "\$7,540",
            color: Colors.redAccent,
          ),
          Divider(height: 30.h, color: Colors.white24),
          SummaryRow(label: "Balance", value: "\$10,460", color: Colors.white),
        ],
      ),
    );
  }
}
