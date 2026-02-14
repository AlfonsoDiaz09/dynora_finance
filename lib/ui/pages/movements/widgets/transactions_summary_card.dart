import 'package:flutter/material.dart';

class TransactionsSummaryCard extends StatelessWidget {
  const TransactionsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _SummaryItem(
            title: "Ingresos",
            amount: "\$18,000",
            color: Colors.greenAccent,
          ),
          _SummaryItem(
            title: "Gastos",
            amount: "\$7,540",
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
