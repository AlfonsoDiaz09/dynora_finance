import 'package:flutter/material.dart';
import 'recent_transaction_item.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Movimientos recientes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 16),

        RecentTransactionItem(
          title: "Amazon",
          date: "Hoy",
          amount: 320,
          type: TransactionType.expense,
        ),

        SizedBox(height: 12),

        RecentTransactionItem(
          title: "Nómina",
          date: "Ayer",
          amount: 15000,
          type: TransactionType.income,
        ),
      ],
    );
  }
}
