import 'package:flutter/material.dart';

class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        /// Selector de mes
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.05),
            ),
            child: const Text(
              "Febrero 2026",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),

        const SizedBox(width: 12),

        /// Filtro tipo
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
          child: const Icon(Icons.filter_list, color: Colors.white),
        ),

        const SizedBox(width: 12),

        /// Buscar
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
          child: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }
}
