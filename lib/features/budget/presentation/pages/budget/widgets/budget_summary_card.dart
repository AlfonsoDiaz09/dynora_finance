import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    double total = 2000;
    double spent = 690;
    double remaining = total - spent;
    double percent = spent / total;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [Color(0xff7F00FF), Color(0xffE100FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Presupuesto mensual", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 8.h),
          Text(
            "\$${remaining.toStringAsFixed(0)} disponibles",
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
            "\$${spent.toStringAsFixed(0)} de \$${total.toStringAsFixed(0)} usados",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
