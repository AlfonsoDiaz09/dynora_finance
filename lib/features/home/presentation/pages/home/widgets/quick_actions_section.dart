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
    required this.onDebts,
    required this.onLoans,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onCards;
  final VoidCallback onStats;
  final VoidCallback onDebts;
  final VoidCallback onLoans;

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
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
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
            QuickActionCard(
              icon: Icons.handshake_rounded,
              title: "Me deben",
              onTap: onDebts,
            ),
            QuickActionCard(
              icon: Icons.account_balance_rounded,
              title: "Préstamos",
              onTap: onLoans,
            ),
          ],
        ),
      ],
    );
  }
}
