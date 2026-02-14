import 'package:flutter/material.dart';

class StatisticsSummaryCard extends StatelessWidget {
  const StatisticsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xff1E1E2D), Color(0xff25253A)],
        ),
      ),
      child: Column(
        children: const [

          _SummaryRow(
            label: "Ingresos",
            value: "\$18,000",
            color: Colors.greenAccent,
          ),

          SizedBox(height: 16),

          _SummaryRow(
            label: "Gastos",
            value: "\$7,540",
            color: Colors.redAccent,
          ),

          Divider(height: 30, color: Colors.white24),

          _SummaryRow(
            label: "Balance",
            value: "\$10,460",
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
