import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'quick_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onCards,
    required this.onStats,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onCards;
  final VoidCallback onStats;

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
            QuickActionCard(
              icon: Icons.add,
              title: "Agregar gasto",
              onTap: onAddExpense,
            ),
            QuickActionCard(
              icon: Icons.trending_up,
              title: "Agregar ingreso",
              onTap: onAddIncome,
            ),
            QuickActionCard(
              icon: Icons.credit_card,
              title: "Tarjetas",
              onTap: onCards,
            ),
            QuickActionCard(
              icon: Icons.bar_chart,
              title: "Estadísticas",
              onTap: onStats,
            ),
          ],
        ),
      ],
    );
  }
}
