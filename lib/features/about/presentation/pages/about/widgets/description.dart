import 'package:dynora_finance/ui/widgets/info_card.dart';
import 'package:flutter/material.dart';

class Description extends StatelessWidget {
  const Description({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: "Dynora Finances",
      child: Text(
        "Dynora es una aplicación diseñada para ayudarte a llevar el control de tus gastos e ingresos de forma clara, simple y sin complicaciones.\n\nNuestro objetivo es que tomes mejores decisiones financieras con información visual, accesible y confiable.",
      ),
    );
  }
}
