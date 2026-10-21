import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'recent_movement_item.dart';

class RecentMovementsSection extends StatelessWidget {
  const RecentMovementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Movimientos recientes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        RecentMovementItem(
          title: "Amazon",
          date: "Hoy",
          amount: 320,
          type: MovementType.expense,
        ),
        SizedBox(height: 12.h),
        RecentMovementItem(
          title: "Nómina",
          date: "Ayer",
          amount: 15000,
          type: MovementType.income,
        ),
        SizedBox(height: 12.h),
        RecentMovementItem(
          title: "Asesoría flutter",
          date: "Ayer",
          amount: 1398.56,
          type: MovementType.payment,
        ),
      ],
    );
  }
}
