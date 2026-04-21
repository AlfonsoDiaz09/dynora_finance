import 'package:dynora_finance/ui/widgets/bullet.dart';
import 'package:dynora_finance/ui/widgets/info_card.dart';
import 'package:flutter/material.dart';

class Functionalities extends StatelessWidget {
  const Functionalities({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: "¿Qué puedes hacer con Dynora?",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bullet(text: "Registrar gastos e ingresos"),
          Bullet(text: "Visualizar tu dinero de forma clara"),
          Bullet(text: "Mantener control financiero diario"),
          Bullet(text: "Usar una app simple y fácil de entender"),
        ],
      ),
    );
  }
}
