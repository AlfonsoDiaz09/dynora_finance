import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final bool isExpense;

  const TransactionItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? Colors.redAccent : Colors.greenAccent;
    final prefix = isExpense ? "-" : "+";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$prefix\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
