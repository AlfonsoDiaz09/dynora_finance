import 'package:flutter/material.dart';

class CategoryBudgetCard extends StatelessWidget {
  final String category;
  final double spent;
  final double total;

  const CategoryBudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double percent = spent / total;
    double remaining = total - spent;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Título + restante
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                "\$${remaining.toStringAsFixed(0)} libres",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent > 0.9 ? Colors.red : Colors.purpleAccent,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "\$${spent.toStringAsFixed(0)} de \$${total.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
