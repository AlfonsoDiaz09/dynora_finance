import 'package:flutter/material.dart';

class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    double total = 2000;
    double spent = 690;
    double remaining = total - spent;
    double percent = spent / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xff7F00FF), Color(0xffE100FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Presupuesto mensual",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${remaining.toStringAsFixed(0)} disponibles",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          /// Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "\$${spent.toStringAsFixed(0)} de \$${total.toStringAsFixed(0)} usados",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
