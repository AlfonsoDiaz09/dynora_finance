import 'package:flutter/material.dart';
import 'transaction_item.dart';

class TransactionGroup extends StatelessWidget {
  final String date;

  const TransactionGroup({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          date,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        const TransactionItem(
          title: "Amazon",
          category: "Compras",
          amount: 320,
          isExpense: true,
        ),

        const SizedBox(height: 12),

        const TransactionItem(
          title: "Nómina",
          category: "Ingreso",
          amount: 15000,
          isExpense: false,
        ),
      ],
    );
  }
}
