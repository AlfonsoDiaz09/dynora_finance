import 'package:flutter/material.dart';

class CategoryChart extends StatelessWidget {
  const CategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [

        Text(
          "Gastos por categoría",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 20),

        _CategoryBar(
          category: "Comida",
          percentage: 0.6,
          color: Colors.orangeAccent,
        ),

        SizedBox(height: 14),

        _CategoryBar(
          category: "Transporte",
          percentage: 0.3,
          color: Colors.blueAccent,
        ),

        SizedBox(height: 14),

        _CategoryBar(
          category: "Suscripciones",
          percentage: 0.2,
          color: Colors.purpleAccent,
        ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String category;
  final double percentage;
  final Color color;

  const _CategoryBar({
    required this.category,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
