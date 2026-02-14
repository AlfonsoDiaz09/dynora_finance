import 'package:flutter/material.dart';

class TrendSection extends StatelessWidget {
  const TrendSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [

          Text(
            "Tendencia mensual",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          Text(
            "⬆ 12% más gasto que el mes anterior",
            style: TextStyle(
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}
