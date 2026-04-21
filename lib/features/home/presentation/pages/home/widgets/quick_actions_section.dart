import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'quick_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Acciones rápidas",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            QuickActionCard(icon: Icons.add, title: "Agregar gasto"),
            QuickActionCard(icon: Icons.trending_up, title: "Agregar ingreso"),
            QuickActionCard(icon: Icons.credit_card, title: "Tarjetas"),
            QuickActionCard(icon: Icons.bar_chart, title: "Estadísticas"),
          ],
        ),
      ],
    );
  }
}
